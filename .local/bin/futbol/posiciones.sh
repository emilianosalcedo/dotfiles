#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#===============================================================================

bold="\e[1m"
red="\e[1;31m"
def="\e[0m"
blue="\033[1;34m"
cyan="\033[1;36m"
def2="\033[0m"
green="\033[1;32m"
orange="\033[1;33m"
black="\033[1;30m"

url_spa="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/espana/pages/es/posiciones.html"
url_premier="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/premierleague/pages/es/posiciones.html"
url_calcio="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/italia/pages/es/posiciones.html"
url_bundes="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/alemania/pages/es/posiciones.html"
url_uru="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/uruguay/pages/es/posiciones.html"
url_arg="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/primeraa/pages/es/posiciones.html"
url_chile="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/chile/pages/es/posiciones.html"
url_ecu="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/ecuador/pages/es/posiciones.html"
url_par="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/paraguay/pages/es/posiciones.html"
url_bol="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/bolivia/pages/es/posiciones.html"
url_peru="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/peru/pages/es/posiciones.html"
url_ven="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/venezuela/pages/es/posiciones.html"
url_col="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/colombia/pages/es/posiciones.html"
url_mex="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/mexico/pages/es/posiciones.html"
url_bnac="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/nacionalb/pages/es/posiciones.html"
url_bra="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/brasileirao/pages/es/posiciones.html"

tmp1="/tmp/posiciones.tmp"
tmp_utf="/tmp/posiciones.tmp.utf8"
tmp_html="/tmp/posiciones.html"
tmp_html2="/tmp/posiciones.html2"

#===============================================================================

case "$1" in
  [Ee][s][p][a][ñ][a] ) url="${url_spa}" ;;
  [Pp][r][e][m][i][e][r] ) url="${url_premier}" ;;
  [Cc][a][l][c][i][o] ) url="${url_calcio}" ;;
  [Bb][u][n][d][e][s][l][i][g][a] ) url="${url_bundes}" ;;
  [Uu][r][u][g][u][a][y] ) url="${url_uru}" ;;
  [Aa][r][g][e][n][t][i][n][a] ) url="${url_arg}" ;;
  [Cc][h][i][l][e] ) url="${url_chile}" ;;
  [Ee][c][u][a][d][o][r] ) url="${url_ecu}" ;;
  [Pp][a][r][a][g][u][a][y] ) url="${url_par}" ;;
  [Bb][o][l][i][v][i][a] ) url="${url_bol}" ;;
  [Pp][e][r][u] ) url="${url_peru}" ;;
  [Vv][e][n][e][z][u][e][l][a] ) url="${url_ven}" ;;
  [Cc][o][l][o][m][b][i][a] ) url="${url_col}" ;;
  [Mm][e][x][i][c][o] ) url="${url_mex}" ;;
  [Bb][n][a][c][i][o][n][a][l] ) url="${url_bnac}" ;;
  [Bb][r][a][s][i][l] ) url="${url_bra}" ;;
  * ) url="${url_arg}" ;;
esac

#===============================================================================

rm /tmp/posiciones.* 2> /dev/null
wget -O "${tmp1}" -c -nv "${url}" 2> /dev/null

# Detectamos el mapa de caracteres que se esta usando
regex="armscii8|big5(hkscs)?|cp125[1-5]|euc(jp|kr|tw)|gb(18030|2312|k)|georgianps|iso8859[1-9][0-5]?|koi8[rtu]|pt154|tis620|utf-?8|tcvn57121|rk1048"
codificacion="$(locale | grep -E -i -o "${regex}" |sort -u)"
iconv -f latin1 -t "${codificacion}" "${tmp1}" -o "${tmp_utf}"

sed -n '/<table class="tabla_fase table table-condensed" id="pos_n1">/,/<\/table>/p' "${tmp_utf}" | tr "&" " " > "${tmp_html2}"
sed  '/<img src=/d' "${tmp_html2}" | sed 's/nbsp;//g' | sed 's/<\/div>//g' | \
  sed 's/<div class="border">//g' | sed 's/<span class="badge">//g' | sed 's/<\/span>//g' | \
  sed '/<tr><td colspan="20"><span class="leyenda">/d' | sed '/<span class="p_europa/d' | \
  sed '/<span class="p_desciende/d' > "${tmp_html}"

equipos=(
  $(xpath -q -e '/table/tr//td/text()' "${tmp_html}" | \
  sed -E 's/Ã¡/á/g; s/Ã­/í/g; s/Ã³/ó/g; s/Ã©/é/g; s/Ãº/ú/g; s/Ã±/ñ/g; s/Ãª/ê/g; s/Ã£/ã/g' | tr " " "_")
)

#===============================================================================

cabecera_equipo="EQUIPO"
ancho_equipo="${#cabecera_equipo}"

for (( i=0; i<"${#equipos[*]}"; i++ )); do
  if [[ "${#equipos[$i+1]}" -ge "${ancho_equipo}" ]]; then
    ancho_equipo="${#equipos[$i+1]}"
  fi
done

fmt_char="|%4s | %""${ancho_equipo}""s | %3s | %2s | %2s | %2s | %2s | %2s | %2s | %3s |\n"
fmt_header=( "POS" "${cabecera_equipo}" "PTS" "PJ" "PG" "PE" "PP" "GF" "GC" "DF" )
header="|${red}%4s${def} | ${red}%""${ancho_equipo}""s${def} | ${red}%3s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%3s${def} |\n"
content="|${blue}%4s${def2} | ${blue}%""${ancho_equipo}""s${def2} | ${cyan}%3s${def2} | %2s | %2s | %2s | %2s | %2s | %2s | %3s |\n"
char="$(bc -l <<< "$(printf "${fmt_char}" "${fmt_header[@]}" | wc -c) -1")"

printf "\n${orange}%40s${def}\n\n" "POSICIONES"
printf "%${char}s\n" | tr " " "-"
printf "${header}" "${fmt_header[@]}"
printf "%${char}s\n" | tr " " "-"

for (( i=0; i<"${#equipos[*]}"; i++ )); do
  awk 'BEGIN {
    printf "'"${content}"'", "'${equipos[$i]}'", "'"${equipos[$i+1]//_/ }"'", "'${equipos[$i+2]}'", \
    "'${equipos[$i+3]}'", "'${equipos[$i+4]}'", "'${equipos[$i+5]}'", "'${equipos[$i+6]}'", \
    "'${equipos[$i+7]}'", "'${equipos[$i+8]}'", "'${equipos[$i+9]}'"
  }'

  let i="${i}+9"
done

printf "%${char}s\n" | tr " " "-"

#===============================================================================

# Limpieza
rm /tmp/posiciones.* 2> /dev/null

exit
