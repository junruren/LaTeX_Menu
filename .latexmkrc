# latexmk configuration: XeLaTeX, outputs in ./build
$pdf_mode = 5;                 # 5 = xelatex
$out_dir  = 'build';
$xelatex  = 'xelatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';
