%%
%%
%%
\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{swathesis}[2012/06/12 v0.4
^^J LaTeX document class for Theses at the SWA Group]

% Options.
%
% Language
%  en  -  english (default)
%  de  -  german
%
% Modes
%  draft - drafting mode, esp for todos
%  final - final mode
%
%
% Fonts
%  lmodern - Latin Modern, like TeX default (default)
%  palatino -  Heavier, slightly more readable
%                      Palatino Linotype, Palatino or TeX Gyre Pagella  (xetex)
%                      TeX Gyre Pagella (luatex)
%                      Palladio+Pazo (pdflatex)
%  garamond - Lighter than palatino, heavier than latin modern, 
%                         more readable.
%                      needs EB Garamond:
%                       http://www.georgduffner.at/ebgaramond/
%                          download:
%            https://github.com/downloads/georgd/EB-Garamond/EBGaramond-0.013.zip
%                         unzip and install (xetex) or set
%                         \garamondpath (luatex)
%
% Other
%  print - do not color links
%
\RequirePackage{etoolbox}

\newif\if@swa@german
\newif\if@swa@lncs
\providecommand*\@swa@font{}
\providecommand*\printmode{false}
\providecommand*\swa@miscoptions{}
%

\DeclareOption{bachelor}{\@swa@lncstrue\gdef\swa@degree{bachelor}}
\DeclareOption{master}{\@swa@lncsfalse\gdef\swa@degree{master}}
\DeclareOption{phd}{\@swa@lncsfalse\gdef\swa@degree{phd}}

\DeclareOption{en}{\@swa@germanfalse}
\DeclareOption{de}{\@swa@germantrue}
\DeclareOption{palatino}{\renewcommand*\@swa@font{palatino}}
\DeclareOption{garamond}{\renewcommand*\@swa@font{garamond}}
\DeclareOption{lmodern}{\renewcommand*\@swa@font{lmodern}}
\DeclareOption{print}{\renewcommand*\printmode{true}}

\DeclareOption*{\gappto\swa@miscoptions{\CurrentOption,}}


\ExecuteOptions{master,en,lmodern}
\ProcessOptions\relax



\RequirePackage{expl3}
\RequirePackage{swa-platform}


\newcommand*\location[1]{\renewcommand\@location{#1}}
\providecommand*\@location{}

\ifthenelse{\boolean{@swa@lncs}}{%
  \gdef\swa@cls{llncs}%
  \gappto\swa@miscoptions{a4paper,runningheads,}
}{%
  \gdef\swa@cls{scrbook}%
}
\ifx\swa@miscoptions\empty\relax\else
  \PassOptionsToClass{\swa@miscoptions}{\swa@cls}
\fi
\LoadClass{\swa@cls}

\RequirePackage{swa-language}
\RequirePackage{swa-document}


\RequirePackage{swa-graphics}
\RequirePackage{swa-listings}

\RequirePackage{swa-font}

\ifthenelse{\boolean{@swa@lncs}}{
  \robustify{\email}
}{%
  % only in the koma case
  \RequirePackage{swa-abstract}
  \RequirePackage{swa-bibliography}
}

\RequirePackage{swa-acronyms}
\RequirePackage{swa-statement}


\newcommand\hairspace{\ifmmode\mskip1mu\else\kern0.08em\fi}
\RequirePackage{xspace}



%\recalctypearea
\raggedbottom

\InputIfFileExists {\jobname-names.tex}{
  \ClassInfo{swathesis}{Using names-file `\jobname-names.tex'}
}{
  \ClassInfo{swathesis}{Not using a names-file.}
}

%%% Local Variables: 
%%% mode: latex
%%% End: 
