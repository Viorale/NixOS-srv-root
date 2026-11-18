-- Language servers.
--
-- nvim-lspconfig only supplies the default `cmd`/`filetypes`/`root_markers`
-- for each server; Neovim 0.11+'s `vim.lsp.config`/`vim.lsp.enable` do the
-- rest. There is no Mason here: on NixOS the server binaries come from
-- `programs.neovim.extraPackages` (home/ryuk/nvim.nix), and a server is only
-- enabled when its binary is actually on PATH — add the package, rebuild,
-- and it starts on the next file of that type.

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "saghen/blink.cmp" },
  config = function()
    -- ------------------------------------------------------------------
    -- Capabilities
    -- ------------------------------------------------------------------
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end

    -- Ask servers for the extras we actually render: snippet bodies in
    -- completion, and folding ranges for servers that compute them better than
    -- Treesitter can.
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }

    -- Diagnostic appearance (icons, virtual text, floats, highlights) is owned
    -- by core.diagnostics and configured during startup — nvim-lint publishes
    -- into the same namespace, so it cannot depend on this plugin loading.

    -- ------------------------------------------------------------------
    -- Buffer-local keymaps and per-server tweaks
    -- ------------------------------------------------------------------
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
          return
        end

        local buf = event.buf

        -- Highlight other references to the symbol under the cursor. The
        -- autocommands are buffer-scoped to their own group so detaching one
        -- client doesn't tear down highlighting for the others.
        if client:supports_method("textDocument/documentHighlight") then
          local group = vim.api.nvim_create_augroup("UserLspHighlight" .. buf, { clear = true })

          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = group,
            buffer = buf,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = group,
            buffer = buf,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd("LspDetach", {
            group = group,
            buffer = buf,
            callback = function()
              vim.lsp.buf.clear_references()
              pcall(vim.api.nvim_del_augroup_by_name, "UserLspHighlight" .. buf)
            end,
          })
        end

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
        end

        -- Inlay hints, when the server offers them. On by default: seeing
        -- inferred types is most of the value of having a type-aware server.
        if client:supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = buf })

          map("n", "<leader>ch", function()
            local enabled = not vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
            vim.lsp.inlay_hint.enable(enabled, { bufnr = buf })
            vim.notify("Inlay hints " .. (enabled and "on" or "off"), vim.log.levels.INFO)
          end, "LSP: Toggle inlay hints")
        end

        -- Navigation. fzf-lua gives a searchable, previewable list where the
        -- built-ins would dump straight into the quickfix window; with a single
        -- result it jumps directly (`jump1` in plugins/fzf_lua.lua).
        local function picker(name, fallback)
          return function()
            local ok, fzf = pcall(require, "fzf-lua")
            if ok and fzf[name] then
              fzf[name]({ reuse_win = true })
            else
              fallback()
            end
          end
        end

        map("n", "gd", picker("lsp_definitions", vim.lsp.buf.definition), "LSP: Go to definition")
        map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
        map("n", "gi", picker("lsp_implementations", vim.lsp.buf.implementation), "LSP: Go to implementation")
        map("n", "gr", picker("lsp_references", vim.lsp.buf.references), "LSP: References")
        map("n", "gt", picker("lsp_typedefs", vim.lsp.buf.type_definition), "LSP: Type definition")

        -- Info (border is passed per call; vim.lsp.with is deprecated on 0.11+)
        map("n", "K", function() vim.lsp.buf.hover({ border = "rounded" }) end, "LSP: Hover")
        map("n", "gK", function() vim.lsp.buf.signature_help({ border = "rounded" }) end, "LSP: Signature")
        map("i", "<C-k>", function() vim.lsp.buf.signature_help({ border = "rounded" }) end, "LSP: Signature")

        -- Actions (formatting lives in conform.nvim, see plugins/conform.lua)
        map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
        -- Code actions with a diff preview of what each one would change
        -- (the template used actions-preview.nvim for this).
        map({ "n", "v" }, "<leader>ca", picker("lsp_code_actions", vim.lsp.buf.code_action), "LSP: Code action")

        -- Diagnostic navigation is deliberately *not* here: `vim.diagnostic` is
        -- fed by nvim-lint too, so those keys have to exist in buffers no
        -- language server ever attaches to. See core/keymaps.lua.
      end,
    })

    -- ------------------------------------------------------------------
    -- Servers
    -- ------------------------------------------------------------------
    -- Shared defaults for every server.
    vim.lsp.config("*", { capabilities = capabilities })

    -- Per-server settings. Keys are nvim-lspconfig server names; the binary
    -- each one needs is listed so you know what to add in nvim.nix.
    local servers = {
      -- Lua, for editing this config (lazydev.nvim supplies the library paths).
      -- binary: lua-language-server  (pkgs.lua-language-server)
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            diagnostics = { globals = { "vim" } },
            hint = { enable = true, arrayIndex = "Disable" },
            format = { enable = false }, -- stylua owns formatting, via conform
            telemetry = { enable = false },
          },
        },
      },

      -- Nix, for /etc/nixos. nixd evaluates your flake for option completion.
      -- binary: nixd  (pkgs.nixd)
      nixd = {
        settings = {
          nixd = {
            formatting = { command = { "nixfmt" } },
            -- Option completion for NixOS and Home Manager from your own flake.
            -- Adjust the hostname/user if they ever change.
            options = {
              nixos = {
                expr = '(builtins.getFlake "/etc/nixos").nixosConfigurations.srv-root.options',
              },
              home_manager = {
                expr = '(builtins.getFlake "/etc/nixos").nixosConfigurations.srv-root.options.home-manager.users.type.getSubOptions []',
              },
            },
          },
        },
      },

      -- Python (ML projects). binary: pyright-langserver  (pkgs.pyright)
      pyright = {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "standard",
              autoImportCompletions = true,
            },
          },
        },
      },

      -- Shell scripts. binary: bash-language-server  (pkgs.bash-language-server)
      bashls = {},

      -- YAML: Ansible playbooks, compose files, GitLab CI.
      -- binary: yaml-language-server  (pkgs.yaml-language-server)
      yamlls = {
        settings = {
          yaml = { keyOrdering = false }, -- alphabetical key warnings are noise
        },
      },

      -- JSON. binary: vscode-json-language-server  (pkgs.vscode-langservers-extracted)
      jsonls = {
        settings = {
          json = { validate = { enable = true } },
        },
      },

      -- TOML. binary: taplo  (pkgs.taplo)
      taplo = {},

      -- Markdown (Obsidian notes): links, headings, references.
      -- binary: marksman  (pkgs.marksman)
      marksman = {},

      -- Dockerfiles / Containerfiles.
      -- binary: docker-langserver  (pkgs.dockerfile-language-server)
      dockerls = {},
    }

    for server, config in pairs(servers) do
      vim.lsp.config(server, config)

      -- Only enable a server whose binary exists. `vim.lsp.config(server)`
      -- merges nvim-lspconfig's defaults, so `cmd[1]` is the executable name.
      local resolved = vim.lsp.config[server]
      local cmd = resolved and resolved.cmd
      local exe = type(cmd) == "table" and cmd[1] or nil

      if exe == nil or vim.fn.executable(exe) == 1 then
        vim.lsp.enable(server)
      end
    end
  end,
}
