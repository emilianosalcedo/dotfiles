#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#===============================================================================

red="\033[1;31m"
blue="\033[1;34m"
bold="\033[1m"
def="\033[0m"
cyan="\033[1;36m"
green="\033[1;32m"
orange="\033[1;33m"
black="\033[1;30m"

url_arg="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/primeraa/pages/es/fixture.html"
url_spa="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/espana/pages/es/fixture.html"
url_premier="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/premierleague/pages/es/fixture.html"
url_calcio="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/italia/pages/es/fixture.html"
url_bundes="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/alemania/pages/es/fixture.html"
url_uru="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/uruguay/pages/es/fixture.html"
url_chi="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/chile/pages/es/fixture.html"
url_ven="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/venezuela/pages/es/fixture.html"
url_col="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/colombia/pages/es/fixture.html"
url_mex="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/mexico/pages/es/fixture.html"
url_bnac="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/nacionalb/pages/es/fixture.html"
url_bra="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/brasileirao/pages/es/fixture.html"

tmp1="/tmp/fixture.tmp"
tmp2="/tmp/fixture.tmp2"
tmp_utf="/tmp/fixture.tmp.utf8"
tmp_html="/tmp/fixture.html"
tmp_html2="/tmp/fixture1.html"

#===============================================================================

case "$1" in
  [Aa][r][g][e][n][t][i][n][a] ) url="${url_arg}"; partidosFecha=13; fechasLiga=25 ;;
  [Ee][s][p][a][ñ][a] ) url="${url_spa}"; partidosFecha=10; fechasLiga=38 ;;
  [Pp][r][e][m][i][e][r] ) url="${url_premier}"; partidosFecha=10; fechasLiga=38 ;;
  [Cc][a][l][c][i][o] ) url="${url_calcio}"; partidosFecha=10; fechasLiga=38 ;;
  [Bb][u][n][d][e][s][l][i][g][a] ) url="${url_bundes}"; partidosFecha=9; fechasLiga=34 ;;
  [Uu][r][u][g][u][a][y] ) url="${url_uru}"; partidosFecha=8; fechasLiga=15 ;;
  [Cc][h][i][l][e] ) url="${url_chi}"; partidosFecha=8; fechasLiga=15 ;;
  [Vv][e][n][e][z][u][e][l][a] ) url="${url_ven}"; partidosFecha=10; fechasLiga=19 ;;
  [Cc][o][l][o][m][b][i][a] ) url="${url_col}"; partidosFecha=10; fechasLiga=19 ;;
  [Mm][e][x][i][c][o] ) url="${url_mex}"; partidosFecha=9; fechasLiga=17 ;;
  [Bb][n][a][c][i][o][n][a][l] ) url="${url_bnac}"; partidosFecha=11; fechasLiga=42 ;;
  [Bb][r][a][s][i][l] ) url="${url_bra}"; partidosFecha=9; fechasLiga=38 ;;
  * ) url="${url_arg}"; partidosFecha=13; fechasLiga=25 ;;
esac

#===============================================================================

rm /tmp/fixture.* 2> /dev/null
wget -O "${tmp1}" -c -nv "${url}" 2> /dev/null 

# Detectamos el mapa de caracteres que se esta usando
regex="armscii8|big5(hkscs)?|cp125[1-5]|euc(jp|kr|tw)|gb(18030|2312|k)|georgianps|iso8859[1-9][0-5]?|koi8[rtu]|pt154|tis620|utf-?8|tcvn57121|rk1048"
codificacion="$(locale | grep -E -i -o "${regex}" |sort -u)"
iconv -f latin1 -t "${codificacion}" "${tmp1}" -o "${tmp_utf}"

#===============================================================================

fecha_act="$(grep '="active' "${tmp_utf}" | grep nivel1 | uniq | xpath -q -e '*/a/text()')"
fecha_sig="$(expr "${fecha_act}" + 1)"
fecha_ant="$(expr "${fecha_act}" - 1)"

# Si no se recibe la fecha o es mayor a las que posee la liga se usará la fecha actual.
if [[ -z "$2"  ]]; then
  fecha="${fecha_act}"
elif [[ "$2" -gt "${fechasLiga}" ]]; then
  fecha="${fecha_act}"
else
  fecha="$2"
fi

# tag_aper y tag cierre son los tag que determinan el contenido de la fecha en un div.
# Sirve para solo quedarnos con el texto que interesa parsear.

# tag_aper depende de la fecha
if [[ "${fecha}" -eq "${fecha_act}" ]]; then
  tag_aper='<div class="col-md-12 fecha show" data-fase="nivel_1" data-fecha="nivel1_fecha'${fecha}'">'
else
  tag_aper='<div class="col-md-12 fecha" data-fase="nivel_1" data-fecha="nivel1_fecha'${fecha}'">'
fi

# tag_cierre depende de la fecha
if [[ "${fecha}" -eq "${fechasLiga}" ]]; then
  tag_cierre='<div class="footerCtn">'
elif [[ "${fecha}" -eq "${fecha_ant}" ]]; then
  tag_cierre='<div class="col-md-12 fecha show" data-fase="nivel_1" data-fecha="nivel1_fecha'${fecha_act}'">'
else
  tag_cierre='<div class="col-md-12 fecha" data-fase="nivel_1" data-fecha="nivel1_fecha'$(expr ${fecha} + 1)'">'
fi

# Obtengo el contenido de la fecha a parsear.
sed -n '/'"${tag_aper}"'/,/'"${tag_cierre}"'/p' "${tmp_utf}" | sed 's/'"${tag_cierre}"'//g' | tr "&" " " > "${tmp2}"
sed '1c<div><div><div>\n' "${tmp2}" | sed 's/<\/img>//g' | sed 's/<img src//g' | \
  sed 's/ nbsp;/-/g' | sed 's/ e_[0-9]*//g' | sed '/<div class="footerCtn">/d' > "${tmp_html}"

if [[ "${fecha}" -eq "${fechasLiga}" ]]; then
  head -n -3 "${tmp_html}" > "${tmp_html2}"
  mv "${tmp_html2}" "${tmp_html}"
fi

echo "</div></div>" >> "${tmp_html}"

#===============================================================================

pars_local='//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="equipo col-xs-4"]/text()'
pars_visita='//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="equipo col-xs-4"]/text()'
pars_gol_local='//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="resultado col-xs-3"]/text()'
pars_gol_visita='//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="resultado col-xs-3"]/text()'
pars_dias='//div[@class="dia col-md-3 col-sm-3 col-xs-4 mc-date"]//text()'
pars_horas='//div[@class="hora col-md-3 col-sm-3 col-xs-4 mc-time"]//text()'

parseador="xpath -q -e '%s' "${tmp_html}" | sed -E 's/Ã¡/á/g; s/Ã­/í/g; s/Ã³/ó/g; s/Ã©/é/g; s/Ãº/ú/g; s/Ã±/ñ/g; s/Ãª/ê/g; s/Ã£/ã/g' | tr "'" " "_"'
local=( $(bash -c "$(printf "${parseador}" "${pars_local}")") )
gol_local=( $(bash -c "$(printf "${parseador}" "${pars_gol_local}")") )
gol_visita=( $(bash -c "$(printf "${parseador}" "${pars_gol_visita}")") )
visita=( $(bash -c "$(printf "${parseador}" "${pars_visita}")") )
dias=( $(bash -c "$(printf "${parseador}" "${pars_dias}")") )
horas=( $(bash -c "$(printf "${parseador}" "${pars_horas}")") )

cabecera_local="LOCAL"
cabecera_visitante="VISITANTE"
ancho_local="${#cabecera_local}"
ancho_visitante="${#cabecera_visitante}"

#===============================================================================

ini=0
fin="${partidosFecha}"

for (( i="${ini}"; i<"${fin}"; i++ )); do
  if [[ "${#local[$i]}" -ge "${ancho_local}" ]]; then
    ancho_local="${#local[$i]}"
  fi
  if [[ "${#visita[$i]}" -ge "${ancho_visitante}" ]]; then
    ancho_visitante="${#visita[$i]}"
  fi
done

#===============================================================================

header="|  %-""${ancho_local}""s    [ %-1s ] %-2s [ %-1s ]    %-""${ancho_visitante}""s  | %-11s | %-7s |\n"
content="|  "${red}"%-""${ancho_local}""s"${def}"    [ "${red}"%-1s"${def}" ] %-2s [ "${blue}"%-1s"${def}" ]    "${blue}"%-""${ancho_visitante}""s"${def}"  | %-11s | %-7s |\n"
fmt_header=("${cabecera_local}" "-" " vs " "-"  "${cabecera_visitante}" "DIA" "HORA") 
char="$(bc -l <<< "$(printf "${header}" "${fmt_header[@]}" | wc -c) - 1")"

printf "\n${orange}%50s${def}\n\n" "Resultados Fecha N° ${fecha}"
printf "%${char}s\n" | tr " " -
printf "${header}" "${fmt_header[@]}"
printf "%${char}s\n" | tr " " -

for (( i="${ini}"; i<"${fin}"; i++ )); do
  awk 'BEGIN {
    printf "'"${content}"'", "'"${local[$i]//_/ }"'", "'${gol_local[$i]}'", \
    " vs ", "'${gol_visita[$i]}'", "'"${visita[$i]//_/ }"'", "'${dias[$i]}'", "'"${horas[$i]//_/ }"'"
  }'

  printf "%${char}s\n" | tr " " - 
done

#===============================================================================

# Limpieza
rm /tmp/fixture.* 2> /dev/null

exit
