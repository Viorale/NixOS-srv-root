{ ... }:

{
  # Home Manager verwaltet ab jetzt ~/.bashrc.
  # Nötig, damit fzf und zoxide sich in die Shell einhängen können.
  programs.bash.enable = true;

  programs.bat.enable = true;     # cat mit Syntax-Highlighting
  programs.fd.enable = true;      # schnelle Dateisuche (find-Ersatz)
  programs.fzf.enable = true;     # Fuzzy-Finder: Strg+R = Verlauf, Strg+T = Datei einfügen
  programs.zoxide.enable = true;  # cd mit Gedächtnis: z <Teil des Ordnernamens>
}
