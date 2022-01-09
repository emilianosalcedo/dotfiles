#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#===============================================================================

awk_pars () {
  awk 'BEGIN {
  printf "'"${content}"'", "'"${local[$i]//_/ }"'", "'${gol_local[$i]}'", "vs", \
  "'${gol_visita[$i]}'", "'"${visita[$i]//_/ }"'", "'${dias[$i]}'", "'"${horas[$i]//_/ }"'"
  }'
}

awk_equipos () {
  awk 'BEGIN {
  printf "'"${content}"'", "'${equipos[$j]}'", "'"${equipos[$j+1]//_/ }"'", "'${equipos[$j+2]}'", \
  "'${equipos[$j+3]}'", "'${equipos[$j+4]}'", "'${equipos[$j+5]}'", "'${equipos[$j+6]}'", \
  "'${equipos[$j+7]}'", "'${equipos[$j+8]}'", "'${equipos[$j+9]}'"}'
}

#===============================================================================

tmp1="/tmp/fixture.tmp"
tmp2="/tmp/fixture.tmp2"
tmp_utf="/tmp/fixture.tmp.utf8"
tmp_html="/tmp/fixture.html"
tmp_html2="/tmp/fixture.html2"

tmp_pos="/tmp/posiciones.tmp"
tmp_pos_utf="/tmp/posiciones.tmp.utf8"
tmp_pos_html="/tmp/posiciones.html"
tmp_pos_html2="/tmp/posiciones.html2"

regex="armscii8|big5(hkscs)?|cp125[1-5]|euc(jp|kr|tw)|gb(18030|2312|k)|georgianps|iso8859[1-9][0-5]?|koi8[rtu]|pt154|tis620|utf-?8|tcvn57121|rk1048"
codificacion="$(locale | grep -E -i -o "${regex}" | sort -u)"
parseador="xpath -q -e '%s' "${tmp_html}" | sed -E 's/Ã¡/á/g; s/Ã­/í/g; s/Ã³/ó/g; s/Ã©/é/g; s/Ãº/ú/g; s/Ã±/ñ/g; s/Ãª/ê/g; s/Ã£/ã/g' | tr "'" " "_"'

red="\033[1;31m"
blue="\033[1;34m"
bold="\033[1m"
def="\033[0m"
cyan="\033[1;36m"
green="\033[1;32m"
orange="\033[1;33m"
black="\033[1;30m"

#===============================================================================

playoff () {
  url="$1"
  fase_ini="$2"
  fase_fin="$(expr "$fase_ini" + 1)"
  nombre_fase="$3"

#-------------------------------------------------------------------------------

  rm /tmp/fixture.* 2> /dev/null
  wget -O "${tmp1}" -c -nv "${url}" 2> /dev/null 

  iconv -f latin1 -t "${codificacion}" "${tmp1}" -o "${tmp_utf}"

  sed 's/ show//g' "${tmp_utf}" > "${tmp1}"
  sed -n '/<div class="fase n'"${fase_ini}"' col-md-12 ">/,/<div class="fase n'"${fase_fin}"' col-md-12 ">/p' "${tmp1}" | \
    sed 's/\t//g' | tr "&" " " > "${tmp2}"
  sed 's/<\/img>//g' "${tmp2}" | sed 's/<img src//g' | sed 's/ nbsp;/-/g' | sed 's/ e_[0-9]*//g' | \
    sed '/<div class="footerCtn">/d' | sed '/<div class="fase n'"${fase_fin}"'/d' > "${tmp_html}"

  if [[ "$2" -eq 5 ]]; then
    sed '1c<div><div><div><div><div><div>\n' "${tmp_html}" > "${tmp_html2}"
  else
    sed '1c<div><div><div>\n' "${tmp_html}" > "${tmp_html2}"
  fi

  mv "${tmp_html2}" "${tmp_html}"

#-------------------------------------------------------------------------------

  pars_local='//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="equipo col-xs-4"]/text()'
  pars_gol_local='//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="resultado col-xs-3"]/text()'
  pars_gol_visita='//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="resultado col-xs-3"]/text()'
  pars_visita='//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="equipo col-xs-4"]/text()'
  pars_dias='//div[@class="dia col-md-3 col-sm-3 col-xs-4 mc-date"]//text()'
  pars_horas='//div[@class="hora col-md-3 col-sm-3 col-xs-4 mc-time"]//text()'

  local=( $( bash -c "$(printf "${parseador}" "${pars_local}")" ) )
  gol_local=( $( bash -c "$(printf "${parseador}" "${pars_gol_local}")" ) )
  gol_visita=( $( bash -c "$(printf "${parseador}" "${pars_gol_visita}")" ) )
  visita=( $( bash -c "$(printf "${parseador}" "${pars_visita}")" ) )
  dias=( $( bash -c "$(printf "${parseador}" "${pars_dias}")" ) )
  horas=( $( bash -c "$(printf "${parseador}" "${pars_horas}")" ) )

  cabecera_local="LOCAL"
  ancho_local="${#cabecera_local}"
  cabecera_visitante="VISITANTE"
  ancho_visitante="${#cabecera_visitante}"
  cant_partidos="${#local[*]}"

#-------------------------------------------------------------------------------

  for (( i=0; i<"${cant_partidos}"; i++ )); do
    if [[ "${#local[$i]}" -ge "${ancho_local}" ]]; then
      ancho_local="${#local[$i]}"
    fi

    if [[ "${#visita[$i]}" -ge "${ancho_visitante}" ]]; then
      ancho_visitante="${#visita[$i]}"
    fi
  done

#-------------------------------------------------------------------------------

  header="| %-""${ancho_local}""s [ %-1s ] %-2s [ %-1s ] %-""${ancho_visitante}""s | %-11s | %-7s |\n"
  content="| ${blue}%-""${ancho_local}""s${def} [ ${blue}%-1s${def} ] %-2s [ ${red}%-1s${def} ] ${red}%-""${ancho_visitante}""s${def} | %-11s | %-7s |\n"
  fmt_header=("LOCAL" "-" "vs" "-" "VISITANTE" "DIA" "HORA")
  char="$(bc -l <<< "$(printf "${header}" "${fmt_header[@]}" | wc -c) - 1")"

  printf "\n${orange}%40s${def}\n" "${nombre_fase}"

  for (( i=0; i<"${cant_partidos}"; i++ )); do
    let j="$(( ("$i" / 2) + 1 ))"

    if [[ "$(( "$i" % 2 ))" -eq 0 ]]; then
      printf "\n${cyan}%35s${def}\n" "Llave  $j"
      printf "%${char}s\n" | tr " " -
      printf "${header}" "${fmt_header[@]}"
      printf "%${char}s\n" | tr " " -
    fi

    awk_pars
  done

    printf "\n"
}

#===============================================================================

resultados_grupo () {
  url="$1"
  num_grupo="$2"

#-------------------------------------------------------------------------------

  rm /tmp/fixture.* 2> /dev/null
  wget -O "${tmp1}" -c -nv "${url}" 2> /dev/null 

  iconv -f latin1 -t "${codificacion}" "${tmp1}" -o "${tmp_utf}"

  sed 's/ show//g' "${tmp_utf}" > "${tmp1}"
  sed -n '/<div class="fase n1 col-md-12 ">/,/<div class="fase n2 col-md-12 ">/p' "${tmp1}" | tr "&" " " > "${tmp2}"
  sed '1c<div>\n' "${tmp2}" | sed 's/<img src//g' | sed 's/<\/img>//g' | sed 's/ nbsp;/-/g' | \
    sed 's/ e_[0-9]*//g' | sed '/<div class="footerCtn">/d' | sed '/<div class="fase n2/d' > "${tmp_html}"

#-------------------------------------------------------------------------------

  pars_local='//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'${num_grupo}'"]//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="equipo col-xs-4"]/text()'
  pars_gol_local='//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'${num_grupo}'"]//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="resultado col-xs-3"]/text()'
  pars_gol_visita='//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'${num_grupo}'"]//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="resultado col-xs-3"]/text()'
  pars_visita='//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'${num_grupo}'"]//div[@class="row match-inner"]//div[2]//div[@class="equipo col-xs-4"]/text()'
  pars_dias='//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'${num_grupo}'"]//div[@class="dia col-md-3 col-sm-3 col-xs-4 mc-date"]//text()'
  pars_horas='//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'${num_grupo}'"]//div[@class="hora col-md-3 col-sm-3 col-xs-4 mc-time"]//text()'

  local=( $( bash -c "$(printf "${parseador}" "${pars_local}")" ) )
  gol_local=( $( bash -c "$(printf "${parseador}" "${pars_gol_local}")" ) )
  gol_visita=( $( bash -c "$(printf "${parseador}" "${pars_gol_visita}")" ) )
  visita=( $( bash -c "$(printf "${parseador}" "${pars_visita}")" ) )
  dias=( $( bash -c "$(printf "${parseador}" "${pars_dias}")" ) )
  horas=( $( bash -c "$(printf "${parseador}" "${pars_horas}")" ) )

  cabecera_local="LOCAL"
  ancho_local="${#cabecera_local}"
  cabecera_visitante="VISITANTE"
  ancho_visitante="${#cabecera_visitante}"
  cant_partidos="${#local[*]}"

#-------------------------------------------------------------------------------

  for (( i=0; i<"${cant_partidos}"; i++ )); do
    if [[ "${#local[$i]}" -ge "${ancho_local}" ]]; then
      ancho_local="${#local[$i]}" 
    fi    

    if [[ "${#visita[$i]}" -ge "${ancho_visitante}" ]]; then
      ancho_visitante="${#visita[$i]}"
    fi    
  done

#-------------------------------------------------------------------------------

  fmt_header=("${cabecera_local}" "-" "vs" "-" "${cabecera_visitante}" "DIA" "HORA")
  header="| %-${ancho_local}s [ %-1s ] %-1s [ %-1s ] %-${ancho_visitante}s | %-11s | %-7s |\n"
  content="| ${blue}%-${ancho_local}s${def} [ ${blue}%-1s${def} ] %-1s [ ${red}%-1s${def} ] ${red}%-${ancho_visitante}s${def} | %-11s | %-7s |\n"
  char="$(bc -l <<< "$(printf "${header}" "${fmt_header[@]}" | wc -c) - 1")"

  printf "\n%40s\n" "GRUPO N° ${num_grupo}"

  for (( i=0; i<12; i++ )); do
    let j="$(( ("$i" / 2) + 1 ))"

    if [[ "$(( "$i" % 2 ))" -eq 0 ]]; then
      printf "\n${cyan}%35s${def}\n" "FECHA  $j"
      printf "%${char}s\n" | tr " " -
      printf "${header}" "${fmt_header[@]}"
      printf "%${char}s\n" | tr " " -
    fi

    awk_pars
  done

  printf "\n"
}

#===============================================================================

posiciones () {
    url=$1

#-------------------------------------------------------------------------------

    rm /tmp/posiciones.* 2> /dev/null
    wget -O "${tmp_pos}" -c -nv "${url}" 2> /dev/null
    iconv -f iso-8859-1 -t utf8 "${tmp_pos}" -o "${tmp_pos_utf}"

  sed -n '/<table class="tabla_fase table table-condensed" id="pos_n1">/,/<\/table>/p' "${tmp_pos_utf}" | tr "&" " " > "${tmp_pos_html2}"
  sed  '/<img src=/d' "${tmp_pos_html2}" | sed 's/nbsp;//g' | sed 's/<\/div>//g' | \
    sed 's/<div class="border">//g' | sed 's/<span class="badge">//g' | sed 's/<\/span>//g' | \
    sed '/<tr><td colspan="20"><span class="leyenda">/d' | sed '/<span class="p_europa/d' | \
    sed '/<span class="p_desciende/d' | sed '/><table/c<table>' > "${tmp_pos_html}"

#-------------------------------------------------------------------------------

  equipos=( $(xpath -q -e '/table/tr//td/text()' "${tmp_pos_html}" | sed -E 's/Ã¡/á/g; s/Ã­/í/g; s/Ã³/ó/g; s/Ã©/é/g; s/Ãº/ú/g; s/Ã±/ñ/g; s/Ãª/ê/g; s/Ã£/ã/g' | tr " " "_") )

  cabecera_equipo="EQUIPO"
  ancho_equipo="${#cabecera_equipo}"
  cant_equipos="${#equipos[*]}"

#-------------------------------------------------------------------------------

  for (( i=0; i<"${cant_equipos}"; i++ )); do
    if [[ "${#equipos[$i]}" -ge "${ancho_equipo}" ]]; then
      ancho_equipo="${#equipos[$i]}"
    fi
  done

#-------------------------------------------------------------------------------

  fmt_header=("POS" "${cabecera_equipo}" "PTS" "PJ" "PG" "PE" "PP" "GF" "GC" "DF")
  orig_header="|%4s | %${ancho_equipo}s | %3s | %2s | %2s | %2s | %2s | %2s | %2s | %3s |\n"
  header="|${red}%4s${def} | ${red}%${ancho_equipo}s${def} | ${red}%3s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%3s${def} |\n"
  content="|${blue}%4s${def} | ${blue}%${ancho_equipo}s${def} | ${cyan}%3s${def} | %2s | %2s | %2s | %2s | %2s | %2s | %3s | \n"
  char="$(bc -l <<< "$(printf "${orig_header}" "${fmt_header[@]}" | wc -c) - 1")"

#-------------------------------------------------------------------------------

  printf "\n"

  for (( i=0; i<8; i++ )); do
    printf "${orange}%40s${def}\n" "GRUPO $(expr $i + 1)" 
    printf "%${char}s\n" | tr " " -
    printf "${header}" "${fmt_header[@]}"
    printf "%${char}s\n" | tr " " -

    for (( j="$i"*10*4; j<10*4*("$i"+1); j++)); do
      awk_equipos
      let j="$j+9"
    done

    printf "\n"
  done

  printf "\n"
}

#===============================================================================

url_pos="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/champions/pages/es/posiciones.html"
url_grupo="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/champions/pages/es/fixture.html"
url_8="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/champions/pages/es/fixture.html"
url_4="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/champions/pages/es/fixture.html"
url_semi="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/champions/pages/es/fixture.html"
url_final="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/champions/pages/es/fixture.html"

#===============================================================================

case "$1" in
  [Pp][o][s][i][c][i][o][n][e][s] ) url="${url_pos}"; posiciones "${url}" ;;
  [Gg][r][u][p][o] ) url="${url_grupo}"; resultados_grupo "${url}" "$2" ;;
  [Oo][c][t][a][v][o][s] ) url="${url_8}"; playoff "${url}" 2 "8° DE FINAL" ;;
  [Cc][u][a][r][t][o][s] ) url="${url_4}"; playoff "${url}" 3 "4° DE FINAL" ;;
  [Ss][e][m][i] ) url="${url_semi}"; playoff "${url}" 4 "SEMIFINAL" ;;
  [Ff][i][n][a][l]) url="${url_final}"; playoff "${url}" 5 "FINAL" ;;
  * ) ;;
esac

#===============================================================================

# Limpieza
rm /tmp/fixture.* 2> /dev/null
rm /tmp/posiciones.* 2> /dev/null

exit
