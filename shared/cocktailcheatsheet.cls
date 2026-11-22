% =====================================================================
%  cocktailcheatsheet.cls  --  bartender's recipe cheatsheet (US Letter)
% ---------------------------------------------------------------------
%  Same fonts, colours and glass icons as cocktailmenu, on full Letter
%  pages (not imposed). Build like a menu: `make E=<event>` or VS Code.
%
%    \sheetheader{English title}{中文标题}{right-hand info}
%    \sheetsection{English}{中文}
%    \begin{recipe}{name=..., name-zh=..., glass=..., abv=..., yield=...,
%                   method=..., serve=..., garnish=..., source=...}
%      \begin{ingredients}
%        \ing{60 mL}{2 oz}{Bourbon}{波本威士忌}
%      \end{ingredients}
%      \prep{...}  \serve{...}  \method{...}  \tip{...}
%    \end{recipe}
%    \begin{checklist} \item ... \end{checklist}
%  Two recipes side by side (same height):
%    \noindent\begin{recipe}[half=row1]{...}...\end{recipe}\hfill
%    \begin{recipe}[half=row1]{...}...\end{recipe}\par\rowgap
% =====================================================================
\NeedsTeXFormat{LaTeX2e}[2022/06/01]
\ProvidesClass{cocktailcheatsheet}[2026/11/21 v1.0 Bartender cheatsheet]

\LoadClass[frame=none]{cocktailmenu}
\geometry{paperwidth=8.5in, paperheight=11in, margin=0.45in}
\menusetup{spread=false}

\RequirePackage{array}
\RequirePackage{tabularx}
\RequirePackage{tcolorbox}
\tcbuselibrary{skins}
\newcommand\rowgap{\par\vspace{0.13in}}

\tcbset{
  cms card/.style = {enhanced, colback=white, colframe=menuaccent,
                     boxrule=0.6pt, arc=2.5pt, left=7pt, right=7pt,
                     top=6pt, bottom=6pt, before skip=0pt, after skip=8pt},
  cms panel/.style = {cms card, colback=menuaccent!5},
  % two cards side by side; give both the same equal height group:
  %   \begin{recipe}[half=row1]{...}...\end{recipe}\hfill
  %   \begin{recipe}[half=row1]{...}...\end{recipe}\par
  half/.style = {width=\dimexpr(\linewidth-0.16in)/2\relax, nobeforeafter,
                 box align=top, equal height group=#1},
}

\ExplSyntaxOn
\tl_new:N \l__cms_name_tl
\tl_new:N \l__cms_name_zh_tl
\tl_new:N \l__cms_glass_tl
\tl_new:N \l__cms_abv_tl
\tl_new:N \l__cms_yield_tl
\tl_new:N \l__cms_method_tl
\tl_new:N \l__cms_serve_tl
\tl_new:N \l__cms_garnish_tl
\tl_new:N \l__cms_source_tl
\dim_new:N \l__cms_text_dim

\keys_define:nn { cocktailsheet / recipe }
  {
    name    .tl_set:N = \l__cms_name_tl ,
    name-zh .tl_set:N = \l__cms_name_zh_tl ,
    glass   .tl_set:N = \l__cms_glass_tl ,
    abv     .tl_set:N = \l__cms_abv_tl ,
    yield   .tl_set:N = \l__cms_yield_tl ,
    method  .tl_set:N = \l__cms_method_tl ,
    serve   .tl_set:N = \l__cms_serve_tl ,
    garnish .tl_set:N = \l__cms_garnish_tl ,
    source  .tl_set:N = \l__cms_source_tl ,
  }

\cs_new_protected:Npn \__cms_abv:
  {
    \tl_if_blank:VF \l__cms_abv_tl
      {
        \str_if_eq:VnTF \l__cms_abv_tl { 0 }
          { 无酒精 ~ Zero ~ proof }
          { ≈ \, \l__cms_abv_tl \% \, ABV }
      }
  }

% one "label: value" piece of the meta line, skipped when empty
\cs_new_protected:Npn \__cms_meta:nN #1#2
  {
    \tl_if_blank:VF #2
      {
        \bool_if:NT \l__cms_meta_started_bool { \quad }
        { \color{menuaccent} #1 } \, #2
        \bool_set_true:N \l__cms_meta_started_bool
      }
  }
\bool_new:N \l__cms_meta_started_bool

\cs_new_protected:Npn \__cms_header:
  {
    \dim_set:Nn \l__cms_text_dim { \linewidth - 0.66in }
    \noindent
    \begin{minipage}[c]{0.58in}
      \centering \glassicon[0.62in]{\l__cms_glass_tl}
    \end{minipage}
    \hfill
    \begin{minipage}[c]{\l__cms_text_dim}
      \raggedright
      { \menunamefont \fontsize{12}{14.5}\selectfont \addfontfeatures{LetterSpace=6}
        \text_uppercase:n { \l__cms_name_tl } \par }
      { \fontsize{11.5}{15}\selectfont \bfseries \l__cms_name_zh_tl \par }
      \skip_vertical:n { 1pt }
      { \fontsize{8.8}{11.5}\selectfont
        { \color{menuaccent} \__cms_abv: }
        \tl_if_blank:VF \l__cms_yield_tl
          { \tl_if_blank:VF \l__cms_abv_tl { \quad } { \color{menuink!80} \l__cms_yield_tl } }
        \par }
      { \fontsize{8.6}{11.5}\selectfont \color{menuink!85}
        \bool_set_false:N \l__cms_meta_started_bool
        \__cms_meta:nN { 手法 } \l__cms_method_tl
        \__cms_meta:nN { 杯 } \l__cms_serve_tl
        \__cms_meta:nN { 装饰 } \l__cms_garnish_tl
        \par }
    \end{minipage}
    \par
    \skip_vertical:n { 5pt }
    { \color{menuaccent!55} \hrule height 0.4pt }
    \skip_vertical:n { 3pt }
  }

% \begin{recipe}[<tcolorbox options>]{<keys>}
\NewDocumentEnvironment { recipe } { O{} m }
  {
    \keys_set:nn { cocktailsheet / recipe } {#2}
    \begin{tcolorbox}[cms~card, #1]
    \__cms_header:
  }
  {
    \tl_if_blank:VF \l__cms_source_tl
      {
        \par \skip_vertical:n { 4pt }
        { \fontsize{7.4}{9.4}\selectfont \color{menuink!60}
          配方来源 ~ Spec: ~ \l__cms_source_tl \par }
      }
    \end{tcolorbox}
  }

% Page header with double rule
\NewDocumentCommand \sheetheader { m m m }
  {
    \par \noindent
    { \menudisplayfont \fontsize{21}{25}\selectfont \addfontfeatures{LetterSpace=12}
      \text_uppercase:n {#1} }
    \hspace{0.7em}
    { \CJKfamily{menuzhdisplay} \fontsize{14}{25}\selectfont
      \group_begin: \xeCJKsetup { CJKglue = { \hskip 0.25em } } #2 \group_end: }
    \hfill
    { \fontsize{9.5}{12}\selectfont \color{menuink!75} #3 }
    \par \skip_vertical:n { 3pt }
    { \color{menuaccent} \hrule height 0.8pt }
    \skip_vertical:n { 1.5pt }
    { \color{menuaccent} \hrule height 0.3pt }
    \skip_vertical:n { 8pt }
  }

% Small ruled section label
\NewDocumentCommand \sheetsection { m m }
  {
    \par \addvspace { 4pt } \noindent
    { \menunamefont \fontsize{9}{12}\selectfont \addfontfeatures{LetterSpace=14}
      \color{menuaccent} \text_uppercase:n {#1} }
    \hspace{0.5em}
    { \fontsize{9.5}{12}\selectfont \color{menuaccent} #2 }
    \hspace{0.6em}
    { \color{menuaccent!60} \leaders \hrule height 3.2pt depth -2.85pt \hfill }
    \par \nopagebreak \skip_vertical:n { 5pt }
  }
\ExplSyntaxOff

% Ingredient table: amount | alternative amount | English · 中文
\newenvironment{ingredients}
  {\par\noindent\fontsize{10.6}{14}\selectfont
   \renewcommand\arraystretch{1.05}%
   \tabularx{\linewidth}{@{}>{\raggedleft\bfseries}p{0.74in}@{\hspace{5pt}}%
                          >{\raggedright\leavevmode\color{menuink!60}\fontsize{8.6}{14}\selectfont}p{0.46in}@{\hspace{3pt}}%
                          >{\raggedright\arraybackslash}X@{}}}
  {\endtabularx\par}
\newcommand\ing[4]{#1 & #2 & #3\ \ \mbox{\color{menuink!80}\fontsize{9.8}{14}\selectfont #4}\\}

% Steps
\newcommand\recipestep[2]{\par\smallskip\noindent
  {\fontsize{10}{13.8}\selectfont{\color{menuaccent}\bfseries #1}\enspace #2\par}}
\newcommand\prep[1]{\recipestep{提前预制}{#1}}
\newcommand\serve[1]{\recipestep{上桌}{#1}}
\newcommand\method[1]{\recipestep{做法}{#1}}
\newcommand\tip[1]{\par\smallskip\noindent
  {\fontsize{8.6}{11.5}\selectfont\color{menuink!80}{\color{menuaccent}\bfseries 注}\enspace #1\par}}

% Checklist with drawn boxes
\newcommand\checkboxmark{\raisebox{-0.5pt}{\tikz\draw[menuaccent, line width=0.5pt] (0,0) rectangle (7.5pt,7.5pt);}}
\newenvironment{checklist}
  {\list{\checkboxmark}{\leftmargin=15pt \labelwidth=10pt \labelsep=5pt
     \itemsep=2.5pt \parsep=0pt \topsep=2pt}\fontsize{9.4}{12.6}\selectfont\raggedright}
  {\endlist}

\endinput
