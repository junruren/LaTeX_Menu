% =====================================================================
%  cocktailmenu.cls  --  bilingual (English / Chinese) cocktail menu
% ---------------------------------------------------------------------
%  Page  : 5.5in x 8.5in panels (US Letter folded in half)
%  Engine: XeLaTeX  (run `make`, or build from VS Code / LaTeX Workshop)
%
%  Class options (all can also be changed later with \menusetup{...}):
%    script = sc | tc               Simplified / Traditional Chinese fonts
%    layout = stacked | parallel    ZH under EN, or EN | ZH side by side
%    lang   = both | en | zh        which language(s) to print
%    frame  = all | cover | none    decorative double-rule border
%
%  Main commands (see menu.tex for a complete example):
%    \menucover{title=..., title-zh=..., ...}
%    \menusection{English}{中文}
%    \cocktail{name=..., name-zh=..., glass=..., ingredients={a, b},
%              ingredients-zh={甲, 乙}, taste=..., taste-zh=..., abv=18}
%    \spiritgroup{Scotch}{苏格兰}
%    \spirit{name=..., name-zh=..., origin=..., taste=..., abv=43}
%    \menutext{English}{中文}   \menufooter{English}{中文}   \nextpanel
% =====================================================================
\NeedsTeXFormat{LaTeX2e}[2022/06/01]
\ProvidesClass{cocktailmenu}[2026/11/21 v1.0 Bilingual cocktail & spirits menu]

\LoadClass[10pt]{article}

\RequirePackage{iftex}
\RequireXeTeX

\RequirePackage[paperwidth=5.5in, paperheight=8.5in,
                top=0.62in, bottom=0.58in, left=0.62in, right=0.62in]{geometry}
\RequirePackage{fontspec}
\RequirePackage{xeCJK}
\RequirePackage{xcolor}
\RequirePackage{cocktailglasses}

% Middle dot: system fonts place U+00B7 inconsistently (full-width in Songti,
% off-centre in Baskerville), so every `·' typed in the menu is replaced by a
% small drawn dot in the accent colour. Use \menudot explicitly if you prefer.
\RequirePackage{newunicodechar}
\NewDocumentCommand\menudot{}{%
  \raisebox{\dimexpr 0.5ex - 0.075em\relax}{%
    \tikz\fill[menuaccent] (0,0) circle [radius=0.075em];}}
\newunicodechar{·}{\menudot}

\pagestyle{empty}
\setlength\parindent{0pt}
\setlength\parskip{0pt}
\raggedbottom

% ---------------------------------------------------------------------
%  Colours
% ---------------------------------------------------------------------
\definecolor{menuink}{HTML}{1E1B18}      % body text
\definecolor{menuaccent}{HTML}{8A6A3B}   % antique brass: rules, ABV, ornaments

% ---------------------------------------------------------------------
%  Fonts  (all ship with macOS)
%  Override in your preamble, e.g.
%    \setmainfont{Hoefler Text}
%    \renewfontfamily\menudisplayfont{Bodoni 72}
%    \setCJKmainfont{STSong}
%    \setCJKfamilyfont{menuzhdisplay}{Kaiti SC}
% ---------------------------------------------------------------------
\setmainfont{Baskerville}[
  BoldFont       = {Baskerville SemiBold},
  BoldItalicFont = {Baskerville SemiBold Italic}]
\newfontfamily\menudisplayfont{Didot}          % cover title, section titles
\newfontfamily\menunamefont{Baskerville SemiBold}   % drink & spirit names

\ExplSyntaxOn

% ---------------------------------------------------------------------
%  Variables
% ---------------------------------------------------------------------
\bool_new:N  \l__cm_show_en_bool
\bool_new:N  \l__cm_show_zh_bool
\bool_new:N  \l__cm_zh_first_bool
\bool_new:N  \l__cm_parallel_bool
\bool_new:N  \l__cm_uppercase_bool
\bool_new:N  \l__cm_liquid_bool
\bool_new:N  \l__cm_spread_bool
\tl_new:N    \l__cm_frame_tl
\tl_new:N    \l__cm_script_tl
\bool_new:N  \l__cm_fonts_ready_bool
\tl_new:N    \l__cm_currency_tl
\tl_new:N    \l__cm_sep_tl
\tl_new:N    \l__cm_sep_zh_tl
\tl_new:N    \l__cm_abv_label_tl
\tl_new:N    \l__cm_zero_tl
\tl_new:N    \l__cm_zero_zh_tl
\tl_new:N    \l__cm_glass_color_tl
\tl_new:N    \l__cm_liquid_color_tl
\dim_new:N   \l__cm_icon_height_dim
\dim_new:N   \l__cm_icon_col_dim
\dim_new:N   \l__cm_entry_sep_dim
\dim_new:N   \l__cm_spirit_sep_dim
\dim_new:N   \l__cm_text_dim
\dim_new:N   \l__cm_half_dim

% per-item (reset automatically because every item is typeset in a group)
\tl_new:N    \l__cm_name_tl
\tl_new:N    \l__cm_name_zh_tl
\tl_new:N    \l__cm_glass_tl
\clist_new:N \l__cm_ingr_clist
\clist_new:N \l__cm_ingr_zh_clist
\tl_new:N    \l__cm_taste_tl
\tl_new:N    \l__cm_taste_zh_tl
\tl_new:N    \l__cm_origin_tl
\tl_new:N    \l__cm_origin_zh_tl
\tl_new:N    \l__cm_abv_tl
\tl_new:N    \l__cm_price_tl
\tl_new:N    \l__cm_note_tl
\tl_new:N    \l__cm_note_zh_tl

% cover
\tl_new:N    \l__cm_cover_title_tl
\tl_new:N    \l__cm_cover_title_zh_tl
\tl_new:N    \l__cm_cover_sub_tl
\tl_new:N    \l__cm_cover_sub_zh_tl
\tl_new:N    \l__cm_cover_edition_tl
\tl_new:N    \l__cm_cover_glass_tl
\dim_new:N   \l__cm_cover_glass_dim

% ---------------------------------------------------------------------
%  Chinese fonts
% ---------------------------------------------------------------------
\cs_new_protected:Npn \__cm_set_cjk_fonts:n #1
  {
    \setCJKmainfont
      [ BoldFont = { Songti~#1~Bold },
        ItalicFont = { Kaiti~#1 },          % "italic" Chinese = Kaiti (楷体)
        BoldItalicFont = { Kaiti~#1~Bold } ]
      { Songti~#1 }
    \setCJKsansfont { PingFang~#1 }
    \setCJKmonofont { Songti~#1 }
    \setCJKfamilyfont { menuzhdisplay } { Songti~#1 }
  }
\cs_generate_variant:Nn \__cm_set_cjk_fonts:n { V }

% ---------------------------------------------------------------------
%  Global settings:  \menusetup{key = value, ...}
% ---------------------------------------------------------------------
\keys_define:nn { cocktailmenu / setup }
  {
    script  .choices:nn = { sc, tc }
      {
        \tl_set:Nx \l__cm_script_tl { \str_uppercase:f { \l_keys_choice_tl } }
        \str_if_eq:VnTF \l__cm_script_tl { TC }
          { \tl_set:Nn \l__cm_zero_zh_tl { 無酒精 } }
          { \tl_set:Nn \l__cm_zero_zh_tl { 无酒精 } }
        \bool_if:NT \l__cm_fonts_ready_bool { \__cm_set_cjk_fonts:V \l__cm_script_tl }
      } ,

    layout  .choice: ,
    layout / stacked  .code:n = { \bool_set_false:N \l__cm_parallel_bool } ,
    layout / parallel .code:n = { \bool_set_true:N  \l__cm_parallel_bool } ,

    lang    .choice: ,
    lang / both .code:n =
      { \bool_set_true:N \l__cm_show_en_bool  \bool_set_true:N  \l__cm_show_zh_bool
        \bool_set_false:N \l__cm_zh_first_bool } ,
    lang / en .code:n =
      { \bool_set_true:N \l__cm_show_en_bool  \bool_set_false:N \l__cm_show_zh_bool
        \bool_set_false:N \l__cm_zh_first_bool } ,
    lang / zh .code:n =
      { \bool_set_false:N \l__cm_show_en_bool \bool_set_true:N  \l__cm_show_zh_bool
        \bool_set_true:N  \l__cm_zh_first_bool } ,

    frame   .choices:nn = { all, cover, none }
                          { \tl_set_eq:NN \l__cm_frame_tl \l_keys_choice_tl } ,

    accent       .code:n     = { \definecolor{menuaccent}{HTML}{#1} } ,
    ink          .code:n     = { \definecolor{menuink}{HTML}{#1} } ,
    glass-color  .tl_set:N   = \l__cm_glass_color_tl ,
    liquid-color .tl_set:N   = \l__cm_liquid_color_tl ,
    glass-liquid .bool_set:N = \l__cm_liquid_bool ,

    currency          .tl_set:N   = \l__cm_currency_tl ,
    ingredient-sep    .tl_set:N   = \l__cm_sep_tl ,
    ingredient-sep-zh .tl_set:N   = \l__cm_sep_zh_tl ,
    abv-label         .tl_set:N   = \l__cm_abv_label_tl ,
    zero-proof-label    .tl_set:N = \l__cm_zero_tl ,
    zero-proof-label-zh .tl_set:N = \l__cm_zero_zh_tl ,
    uppercase-names   .bool_set:N = \l__cm_uppercase_bool ,

    icon-height  .dim_set:N  = \l__cm_icon_height_dim ,
    icon-column  .dim_set:N  = \l__cm_icon_col_dim ,
    entry-sep    .dim_set:N  = \l__cm_entry_sep_dim ,
    spirit-sep   .dim_set:N  = \l__cm_spirit_sep_dim ,
    spread       .bool_set:N = \l__cm_spread_bool ,
  }

\NewDocumentCommand \menusetup { m } { \keys_set:nn { cocktailmenu / setup } {#1} }

% Defaults
\keys_set:nn { cocktailmenu / setup }
  {
    zero-proof-label-zh = 无酒精,
    script = sc, layout = stacked, lang = both, frame = all,
    glass-color  = menuink!80,
    liquid-color = menuaccent!28,
    glass-liquid = true,
    currency = {},
    ingredient-sep    = { \nobreak\hspace{0.4em}\menudot\hspace{0.4em} },
    ingredient-sep-zh = { \nobreak\hspace{0.35em}\menudot\hspace{0.35em} },
    abv-label = ABV,
    zero-proof-label = Zero~Proof,
    uppercase-names = true,
    icon-height = 0.6in,
    icon-column = 0.66in,
    entry-sep   = 11pt,
    spirit-sep  = 6pt,
    spread = true,
  }

% Colours that depend on the palette are resolved at \begin{document}
\AtBeginDocument
  {
    \colorlet { glassline }   { \l__cm_glass_color_tl }
    \colorlet { glassliquid } { \l__cm_liquid_color_tl }
    \bool_if:NF \l__cm_liquid_bool { \tikzset { liquid/.style = { fill = none } } }
    \color { menuink }
  }

% ---------------------------------------------------------------------
%  Typography
% ---------------------------------------------------------------------
\cs_new_protected:Npn \__cm_font_name:      { \menunamefont \fontsize{10.8}{13.2}\selectfont \addfontfeatures{LetterSpace=7} }
\cs_new_protected:Npn \__cm_font_name_zh:   { \fontsize{10.5}{13.2}\selectfont \bfseries }
\cs_new_protected:Npn \__cm_font_body:      { \fontsize{9.7}{12}\selectfont }
\cs_new_protected:Npn \__cm_font_body_zh:   { \fontsize{9}{12.2}\selectfont }
\cs_new_protected:Npn \__cm_font_taste:     { \fontsize{9.7}{12}\selectfont \itshape }
\cs_new_protected:Npn \__cm_font_taste_zh:  { \fontsize{9.3}{12.2}\selectfont \itshape }
\cs_new_protected:Npn \__cm_font_small:     { \fontsize{7.6}{9.5}\selectfont }
\cs_new_protected:Npn \__cm_font_abv:       { \fontsize{7.6}{9}\selectfont \addfontfeatures{LetterSpace=6} \color{menuaccent} }
\cs_new_protected:Npn \__cm_font_price:     { \menunamefont \fontsize{10.8}{13.2}\selectfont }

\cs_new_protected:Npn \__cm_case:n #1
  { \bool_if:NTF \l__cm_uppercase_bool { \text_uppercase:n {#1} } {#1} }

% Chinese with extra tracking (used for titles)
\cs_new_protected:Npn \__cm_tracked_zh:nn #1#2
  { \group_begin: \xeCJKsetup { CJKglue = { \hskip #1 } } #2 \group_end: }

% ---------------------------------------------------------------------
%  Building blocks
% ---------------------------------------------------------------------
% Vertical space before an item or heading. With `spread', leftover space on a
% panel is shared equally between the gaps and the bottom of the panel, but the
% first item after a heading always stays attached to that heading.
\bool_new:N \g__cm_after_heading_bool
\cs_new_protected:Npn \__cm_vskip:n #1
  {
    \bool_if:NTF \g__cm_after_heading_bool
      { \addvspace { #1 } }
      {
        \bool_if:NTF \l__cm_spread_bool
          { \addvspace { #1 plus 1fil } }
          { \addvspace { #1 plus 2pt } }
      }
    \bool_gset_false:N \g__cm_after_heading_bool
  }
\cs_new_protected:Npn \__cm_heading_done:
  { \nopagebreak \bool_gset_true:N \g__cm_after_heading_bool }

\cs_new_protected:Npn \__cm_abv_price:
  {
    \tl_if_blank:VF \l__cm_abv_tl
      {
        { \__cm_font_abv:
          \str_if_eq:VnTF \l__cm_abv_tl { 0 }
            {
              \bool_if:NT \l__cm_show_en_bool { \text_uppercase:n { \l__cm_zero_tl } }
              \bool_if:NT \l__cm_show_zh_bool
                { \bool_if:NT \l__cm_show_en_bool { \enspace } \l__cm_zero_zh_tl }
            }
            { \l__cm_abv_tl \% \tl_if_blank:VF \l__cm_abv_label_tl { \, \l__cm_abv_label_tl } }
        }
      }
    \tl_if_blank:VF \l__cm_price_tl
      { \hspace{0.75em} { \__cm_font_price: \l__cm_currency_tl \l__cm_price_tl } }
  }

\cs_new_protected:Npn \__cm_names:
  {
    \bool_if:NTF \l__cm_zh_first_bool
      {
        \tl_if_blank:VF \l__cm_name_zh_tl { { \__cm_font_name_zh: \l__cm_name_zh_tl } \hspace{0.6em} }
        { \__cm_font_name: \fontsize{8.4}{12.5}\selectfont \__cm_case:n { \l__cm_name_tl } }
      }
      {
        { \__cm_font_name: \__cm_case:n { \l__cm_name_tl } }
        \bool_if:NT \l__cm_show_zh_bool
          { \tl_if_blank:VF \l__cm_name_zh_tl { \hspace{0.55em} { \__cm_font_name_zh: \l__cm_name_zh_tl } } }
      }
  }

\cs_new_protected:Npn \__cm_name_line:
  { \__cm_names: \hfill \__cm_abv_price: \par }

% English description block
\cs_new_protected:Npn \__cm_desc_en:
  {
    \clist_if_empty:NF \l__cm_ingr_clist
      { { \__cm_font_body: \clist_use:Nn \l__cm_ingr_clist { \l__cm_sep_tl } \par } }
    \tl_if_blank:VF \l__cm_taste_tl
      { { \__cm_font_taste: \l__cm_taste_tl \par } }
  }

% Chinese description block
\cs_new_protected:Npn \__cm_desc_zh:
  {
    \clist_if_empty:NF \l__cm_ingr_zh_clist
      { { \__cm_font_body_zh: \clist_use:Nn \l__cm_ingr_zh_clist { \l__cm_sep_zh_tl } \par } }
    \tl_if_blank:VF \l__cm_taste_zh_tl
      { { \__cm_font_taste_zh: \l__cm_taste_zh_tl \par } }
  }

\cs_new_protected:Npn \__cm_note:
  {
    \bool_lazy_or:nnT
      { \bool_lazy_and_p:nn { \l__cm_show_en_bool } { ! \tl_if_blank_p:V \l__cm_note_tl } }
      { \bool_lazy_and_p:nn { \l__cm_show_zh_bool } { ! \tl_if_blank_p:V \l__cm_note_zh_tl } }
      {
        \skip_vertical:n { 1pt }
        { \__cm_font_small: \color{menuaccent}
          \bool_if:NT \l__cm_show_en_bool { \itshape \l__cm_note_tl }
          \bool_lazy_and:nnT { \l__cm_show_en_bool } { \l__cm_show_zh_bool } { \enspace }
          \bool_if:NT \l__cm_show_zh_bool { \upshape \l__cm_note_zh_tl }
          \par }
      }
  }

\cs_new_protected:Npn \__cm_details:
  {
    \bool_lazy_all:nTF
      { { \l__cm_parallel_bool } { \l__cm_show_en_bool } { \l__cm_show_zh_bool } }
      {
        \skip_vertical:n { 1pt }
        \dim_set:Nn \l__cm_half_dim { (\linewidth - 0.9em) / 2 }
        \begin{minipage}[t]{\l__cm_half_dim} \raggedright \__cm_desc_en: \end{minipage}
        \hfill
        \begin{minipage}[t]{\l__cm_half_dim} \raggedright \__cm_desc_zh: \end{minipage}
        \par
      }
      {
        \skip_vertical:n { 1pt }
        \bool_if:NTF \l__cm_zh_first_bool
          { \__cm_desc_zh: \bool_if:NT \l__cm_show_en_bool { \skip_vertical:n { 2pt } \__cm_desc_en: } }
          { \__cm_desc_en: \bool_if:NT \l__cm_show_zh_bool { \skip_vertical:n { 2pt } \__cm_desc_zh: } }
      }
    \__cm_note:
  }

% ---------------------------------------------------------------------
%  Item keys  (shared by \cocktail and \spirit)
% ---------------------------------------------------------------------
\keys_define:nn { cocktailmenu / item }
  {
    name           .tl_set:N    = \l__cm_name_tl ,
    name-zh        .tl_set:N    = \l__cm_name_zh_tl ,
    glass          .tl_set:N    = \l__cm_glass_tl ,
    ingredients    .clist_set:N = \l__cm_ingr_clist ,
    ingredients-zh .clist_set:N = \l__cm_ingr_zh_clist ,
    taste          .tl_set:N    = \l__cm_taste_tl ,
    taste-zh       .tl_set:N    = \l__cm_taste_zh_tl ,
    origin         .tl_set:N    = \l__cm_origin_tl ,
    origin-zh      .tl_set:N    = \l__cm_origin_zh_tl ,
    abv            .tl_set:N    = \l__cm_abv_tl ,
    price          .tl_set:N    = \l__cm_price_tl ,
    note           .tl_set:N    = \l__cm_note_tl ,
    note-zh        .tl_set:N    = \l__cm_note_zh_tl ,
  }

% ---------------------------------------------------------------------
%  \cocktail{...}
% ---------------------------------------------------------------------
\NewDocumentCommand \cocktail { m }
  {
    \par
    \group_begin:
      \keys_set:nn { cocktailmenu / item } {#1}
      \__cm_vskip:n { \l__cm_entry_sep_dim }
      \dim_set:Nn \l__cm_text_dim { \linewidth - \l__cm_icon_col_dim }
      \noindent
      \begin{minipage}[c]{\l__cm_icon_col_dim}
        \glassicon[\l__cm_icon_height_dim]{\l__cm_glass_tl}
      \end{minipage}%
      \begin{minipage}[c]{\l__cm_text_dim}
        \raggedright
        \__cm_name_line:
        \__cm_details:
      \end{minipage}
      \par
    \group_end:
  }

% ---------------------------------------------------------------------
%  Spirits a la carte
% ---------------------------------------------------------------------
\NewDocumentCommand \spiritgroup { m m }
  {
    \par
    \__cm_vskip:n { 12pt }
    \noindent
    \bool_if:NT \l__cm_show_en_bool
      { { \menunamefont \fontsize{8.2}{10}\selectfont \addfontfeatures{LetterSpace=14}
          \color{menuaccent} \text_uppercase:n {#1} } }
    \bool_lazy_and:nnT { \l__cm_show_en_bool } { \l__cm_show_zh_bool } { \hspace{0.5em} }
    \bool_if:NT \l__cm_show_zh_bool
      { { \fontsize{8.4}{10}\selectfont \color{menuaccent} \__cm_tracked_zh:nn { 0.15em } {#2} } }
    \hspace{0.6em}
    { \color{menuaccent!70} \leaders \hrule height 2.9pt depth -2.55pt \hfill }
    \par
    \__cm_heading_done:
    \skip_vertical:n { 2pt }
  }

\NewDocumentCommand \spirit { m }
  {
    \par
    \group_begin:
      \keys_set:nn { cocktailmenu / item } {#1}
      \tl_clear:N \l__cm_abv_label_tl            % spirits show just "43%"
      \cs_set_protected:Npn \__cm_font_name:
        { \menunamefont \fontsize{9}{11.5}\selectfont \addfontfeatures{LetterSpace=6} }
      \cs_set_protected:Npn \__cm_font_name_zh: { \fontsize{9}{11.5}\selectfont \bfseries }
      \cs_set_protected:Npn \__cm_font_price: { \menunamefont \fontsize{9}{11.5}\selectfont }
      \__cm_vskip:n { \l__cm_spirit_sep_dim }
      \noindent
      \begin{minipage}[t]{\linewidth}
        \raggedright
        \__cm_names: \hfill \__cm_abv_price: \par
        \bool_if:NT \l__cm_show_en_bool
          {
            \bool_lazy_or:nnT { ! \tl_if_blank_p:V \l__cm_origin_tl } { ! \tl_if_blank_p:V \l__cm_taste_tl }
              {
                { \__cm_font_body: \l__cm_origin_tl
                  \bool_lazy_and:nnT { ! \tl_if_blank_p:V \l__cm_origin_tl } { ! \tl_if_blank_p:V \l__cm_taste_tl }
                    { \l__cm_sep_tl }
                  \itshape \l__cm_taste_tl \par }
              }
          }
        \bool_if:NT \l__cm_show_zh_bool
          {
            \bool_lazy_or:nnT { ! \tl_if_blank_p:V \l__cm_origin_zh_tl } { ! \tl_if_blank_p:V \l__cm_taste_zh_tl }
              {
                \skip_vertical:n { 1pt }
                { \__cm_font_body_zh: \l__cm_origin_zh_tl
                  \bool_lazy_and:nnT { ! \tl_if_blank_p:V \l__cm_origin_zh_tl } { ! \tl_if_blank_p:V \l__cm_taste_zh_tl }
                    { \l__cm_sep_zh_tl }
                  \__cm_font_taste_zh: \l__cm_taste_zh_tl \par }
              }
          }
      \end{minipage}
      \par
    \group_end:
  }

% ---------------------------------------------------------------------
%  Section titles, ornaments, free text
% ---------------------------------------------------------------------
\NewDocumentCommand \menuornament { O{0.5in} }
  {
    \begin{tikzpicture}[baseline=-0.6ex, line~width=0.4pt, draw=menuaccent, fill=menuaccent]
      \draw (-#1,0) -- (-0.075in,0);
      \draw (#1,0) -- (0.075in,0);
      \fill (0,0.038in) -- (0.038in,0) -- (0,-0.038in) -- (-0.038in,0) -- cycle;
      \fill (-#1,0) circle [radius=0.6pt];
      \fill (#1,0) circle [radius=0.6pt];
    \end{tikzpicture}
  }

\NewDocumentCommand \menusection { m m }
  {
    \par
    \__cm_vskip:n { 20pt }
    \group_begin:
      \centering
      \bool_if:NT \l__cm_show_en_bool
        {
          { \menudisplayfont \fontsize{14.5}{17}\selectfont
            \addfontfeatures{LetterSpace=22}
            \hspace*{0.22em} \text_uppercase:n {#1} \par }
        }
      \bool_if:NT \l__cm_show_zh_bool
        {
          \skip_vertical:n { 3pt }
          { \CJKfamily{menuzhdisplay} \fontsize{10}{12}\selectfont \color{menuink!85}
            \__cm_tracked_zh:nn { 0.35em } {#2} \par }
        }
      \skip_vertical:n { 5pt }
      \menuornament \par
    \group_end:
    \__cm_heading_done:
    \skip_vertical:n { 2pt }
  }

% \menutext{English}{中文} : short centred paragraph (intro, house rules...)
\NewDocumentCommand \menutext { m m }
  {
    \par \addvspace{6pt}
    \group_begin:
      \centering
      \bool_if:NT \l__cm_show_en_bool { { \__cm_font_taste: #1 \par } }
      \bool_lazy_and:nnT { \l__cm_show_en_bool } { \l__cm_show_zh_bool } { \skip_vertical:n { 2pt } }
      \bool_if:NT \l__cm_show_zh_bool { { \__cm_font_body_zh: #2 \par } }
    \group_end:
    \addvspace{6pt}
  }

% \menufooter{English}{中文} : pinned to the bottom of the panel
\NewDocumentCommand \menufooter { m m }
  {
    \par
    \vspace*{0pt plus 1filll}
    \nopagebreak
    \group_begin:
      \centering
      \menuornament[0.35in] \par
      \skip_vertical:n { 4pt }
      \color{menuink!75}
      \bool_if:NT \l__cm_show_en_bool { { \__cm_font_small: \itshape #1 \par } }
      \bool_if:NT \l__cm_show_zh_bool { { \__cm_font_small: #2 \par } }
    \group_end:
  }

\NewDocumentCommand \nextpanel { } { \newpage }

% ---------------------------------------------------------------------
%  Cover:  \menucover{...}
% ---------------------------------------------------------------------
\keys_define:nn { cocktailmenu / cover }
  {
    title        .tl_set:N  = \l__cm_cover_title_tl ,
    title-zh     .tl_set:N  = \l__cm_cover_title_zh_tl ,
    subtitle     .tl_set:N  = \l__cm_cover_sub_tl ,
    subtitle-zh  .tl_set:N  = \l__cm_cover_sub_zh_tl ,
    edition      .tl_set:N  = \l__cm_cover_edition_tl ,
    glass        .tl_set:N  = \l__cm_cover_glass_tl ,
    glass-height .dim_set:N = \l__cm_cover_glass_dim ,
    glass        .initial:n = coupe ,
    glass-height .initial:n = 1.25in ,
  }

\NewDocumentCommand \menucover { m }
  {
    \group_begin:
      \keys_set:nn { cocktailmenu / cover } {#1}
      \centering
      \null \vspace*{0pt plus 1fill}
      \glassicon[\l__cm_cover_glass_dim]{\l__cm_cover_glass_tl} \par
      \skip_vertical:n { 26pt }
      { \menudisplayfont \fontsize{27}{31}\selectfont \addfontfeatures{LetterSpace=14}
        \hspace*{0.14em} \text_uppercase:n { \l__cm_cover_title_tl } \par }
      \bool_if:NT \l__cm_show_zh_bool
        {
          \tl_if_blank:VF \l__cm_cover_title_zh_tl
            {
              \skip_vertical:n { 8pt }
              { \CJKfamily{menuzhdisplay} \fontsize{17}{20}\selectfont
                \__cm_tracked_zh:nn { 0.6em } { \l__cm_cover_title_zh_tl } \par }
            }
        }
      \skip_vertical:n { 14pt }
      \menuornament[0.7in] \par
      \skip_vertical:n { 12pt }
      \bool_if:NT \l__cm_show_en_bool
        {
          { \fontsize{11}{14}\selectfont \itshape \l__cm_cover_sub_tl \par }
        }
      \bool_if:NT \l__cm_show_zh_bool
        {
          \tl_if_blank:VF \l__cm_cover_sub_zh_tl
            {
              \skip_vertical:n { 3pt }
              { \fontsize{9.5}{13}\selectfont \__cm_tracked_zh:nn { 0.2em } { \l__cm_cover_sub_zh_tl } \par }
            }
        }
      \vspace*{0pt plus 1.6fill}
      { \__cm_font_abv: \fontsize{7.8}{10}\selectfont \l__cm_cover_edition_tl \par }
      \skip_vertical:n { 4pt }
    \group_end:
    \newpage
  }

% ---------------------------------------------------------------------
%  Decorative frame (drawn behind every page)
% ---------------------------------------------------------------------
\dim_const:Nn \c__cm_frame_inset_dim { 0.3in }
\cs_new_protected:Npn \__cm_draw_frame:
  {
    \put(0,0)
      {
        \begin{tikzpicture}[overlay, draw=menuaccent]
          \draw[line~width=0.75pt]
            (\c__cm_frame_inset_dim, -\c__cm_frame_inset_dim)
            rectangle (\paperwidth - \c__cm_frame_inset_dim, -\paperheight + \c__cm_frame_inset_dim);
          \draw[line~width=0.3pt]
            (\c__cm_frame_inset_dim + 3pt, -\c__cm_frame_inset_dim - 3pt)
            rectangle (\paperwidth - \c__cm_frame_inset_dim - 3pt, -\paperheight + \c__cm_frame_inset_dim + 3pt);
        \end{tikzpicture}
      }
  }

\AddToHook { shipout / background }
  {
    \str_case:Vn \l__cm_frame_tl
      {
        { all }   { \__cm_draw_frame: }
        { cover } { \int_compare:nNnT { \value{page} } = { 1 } { \__cm_draw_frame: } }
      }
  }

% ---------------------------------------------------------------------
%  Class options:  \documentclass[script=tc, layout=parallel]{cocktailmenu}
% ---------------------------------------------------------------------
\ProcessKeyOptions [ cocktailmenu / setup ]
\bool_set_true:N \l__cm_fonts_ready_bool
\__cm_set_cjk_fonts:V \l__cm_script_tl

\ExplSyntaxOff
\endinput
