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
  "'${equipos[$j+7]}'", "'${equipos[$j+8]}'", "'${equipos[$j+9]}'"
  }'
}

#===============================================================================

tmp="/tmp/fixture.tmp"
tmp2="/tmp/fixture.tmp2"
tmp_utf="/tmp/fixture.tmp.utf8"
tmp_html="/tmp/fixture.html"
tmp_html2="/tmp/fixture.html2"

tmp_pos="/tmp/posiciones.tmp"
tmp_pos2=""
tmp_pos_utf="/tmp/posiciones.tmp.utf8"
tmp_pos_html="/tmp/posiciones.html"
tmp_pos_html2="/tmp/posiciones.html2"

regex="armscii8|big5(hkscs)?|cp125[1-5]|euc(jp|kr|tw)|gb(18030|2312|k)|georgianps|iso8859[1-9][0-5]?|koi8[rtu]|pt154|tis620|utf-?8|tcvn57121|rk1048"
codificacion="$(locale | grep -E -i -o "${regex}" | sort -u)"

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
  fase_fin="$(expr "${fase_ini}" + 1)"
  nombre_fase="$3"

#-------------------------------------------------------------------------------

  rm /tmp/fixture.* 2> /dev/null
  wget -O "${tmp}" -c -nv "${url}" 2> /dev/null 

  iconv -f latin1 -t "${codificacion}" "${tmp}" -o "${tmp_utf}"

  sed 's/ show//g' "${tmp_utf}" > "${tmp}"
  sed -n '/<div class="fase n'"${fase_ini}"' col-md-12 ">/,/<div class="fase n'"${fase_fin}"' col-md-12 ">/p' "${tmp}" | tr "&" " " > "${tmp2}"
  sed 's/<\/img>//g' "${tmp2}" | sed 's/<img src//g' | sed 's/ nbsp;/-/g' | sed 's/ e_[0-9]*//g' | \
    sed '/<div class="footerCtn">/d' | sed '/<div class="fase n'"${fase_fin}"'/d' > "${tmp_html}"

  if [[ "$2" -eq 8 ]]; then
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

  parseador="xpath -q -e '%s' "${tmp_html}" | sed -E 's/Ã¡/á/g; s/Ã­/í/g; s/Ã³/ó/g; s/Ã©/é/g; s/Ãº/ú/g; s/Ã±/ñ/g; s/Ãª/ê/g; s/Ã£/ã/g' | tr "'" " "_"'
  local=( $( bash -c "$(printf "$parseador" "${pars_local}")" ) )
  gol_local=( $( bash -c "$(printf "$parseador" "${pars_gol_local}")" ) )
  gol_visita=( $( bash -c "$(printf "$parseador" "${pars_gol_visita}")" ) )
  visita=( $( bash -c "$(printf "$parseador" "${pars_visita}")" ) )
  dias=( $( bash -c "$(printf "$parseador" "${pars_dias}")" ) )
  horas=( $( bash -c "$(printf "$parseador" "${pars_horas}")" ) )

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

#-------------------------------------------------------------------------------

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
  wget -O "${tmp}" -c -nv "${url}" 2> /dev/null 

  iconv -f latin1 -t "${codificacion}" "${tmp}" -o "${tmp_utf}"

  sed 's/ show//g' "${tmp_utf}" > "${tmp}"
  sed -n '/<div class="fase n4 col-md-12 ">/,/<div class="fase n5 col-md-12 ">/p' "${tmp}" | tr "&" " " > "${tmp2}"
  sed '1c<div>\n' "${tmp2}" | sed 's/<\/img>//g' | sed 's/<img src//g' | sed 's/ nbsp;/-/g' | \
  sed 's/ e_[0-9]*//g' | sed '/<div class="footerCtn">/d' | sed '/<div class="fase n5/d' > "${tmp_html}"

#-------------------------------------------------------------------------------

  pars_local='//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="equipo col-xs-4"]/text()'
  pars_gol_local='//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="col-md-5 col-sm-5 col-xs-10 local"]//div[@class="resultado col-xs-3"]/text()'
  pars_gol_visita='//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="resultado col-xs-3"]/text()'
  pars_visita='//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="col-md-5  col-sm-5 col-xs-10 visitante"]//div[@class="equipo col-xs-4"]/text()'
  pars_dias='//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="dia col-md-3 col-sm-3 col-xs-4 mc-date"]//text()'
  pars_horas='//div[@class="col-lg-6 col-md-12 fecha"][@data-grupo="'$num_grupo'"]//div[@class="hora col-md-3 col-sm-3 col-xs-4 mc-time"]//text()'

  parseador="xpath -q -e '%s' "${tmp_html}" | sed -E 's/Ã¡/á/g; s/Ã­/í/g; s/Ã³/ó/g; s/Ã©/é/g; s/Ãº/ú/g; s/Ã±/ñ/g; s/Ãª/ê/g; s/Ã£/ã/g' | tr "'" " "_"'
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

  header="| %-"${ancho_local}"s [ %-1s ] %-2s [ %-1s ] %-"${ancho_visitante}"s | %-10s | %-7s |\n"
  content="| ${blue}%-"${ancho_local}"s${def} [ ${blue}%-1s${def} ] %-2s [ ${red}%-1s${def} ] ${red}%-"${ancho_visitante}"s${def} | %-10s | %-7s |\n"
  fmt_header=("${cabecera_local}" "-" "vs" "-" "${cabecera_visitante}" "DIA" "HORA")
  char="$(bc -l <<< "$(printf "${header}" "${fmt_header[@]}" | wc -c) - 1")"

#-------------------------------------------------------------------------------

  printf "\n${orange}%40s${def}\n" "GRUPO N° ${num_grupo}"

  for (( i=0; i<12; i++ )); do
    let j="$(( ("$i" / 2) + 1 ))"

    if [[ "$(( "$i" % 2 ))" -eq 0 ]]; then
      printf "\n${cyan}%35s${def}\n" "Fecha  ${j}"
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

  sed -n '/<table class="tabla_fase table table-condensed" id="pos_n4">/,/<\/table>/p' "${tmp_pos_utf}" | tr "&" " " > "${tmp_pos_html2}"
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
    
  header="|${red}%4s${def} | ${red}%${ancho_equipo}s${def} | ${red}%3s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%2s${def} | ${red}%3s${def} |\n"
  content="|${blue}%4s${def} | ${blue}%${ancho_equipo}s${def} | ${cyan}%3s${def} | %2s | %2s | %2s | %2s | %2s | %2s | %3s |\n"
  orig_header="|%4s | %${ancho_equipo}s | %3s | %2s | %2s | %2s | %2s | %2s | %2s | %3s |\n"
  fmt_header=("POS" "${cabecera_equipo}" "PTS" "PJ" "PG" "PE" "PP" "GF" "GC" "DF")
  char="$(bc -l <<< "$(printf "${orig_header}" "${fmt_header[@]}" | wc -c) - 1")"

#-------------------------------------------------------------------------------

  printf "\n"

  for (( i=0; i<8; i++ )); do
    printf "${orange}%35s${def}\n" "GRUPO $(expr $i + 1)" 
    printf "%${char}s\n" | tr " " -
    printf "${header}" "${fmt_header[@]}"
    printf "%${char}s\n" | tr " " -

    for (( j="$i"*10*4; j<10*4*("$i"+1); j++ )); do
      awk_equipos

      let j="$j+9"
    done

    printf "\n"
  done
}

#===============================================================================

url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/libertadores/pages/es/fixture.html"
url_pos="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/libertadores/pages/es/posiciones.html"

#===============================================================================

case "$1" in
  [Pp][o][s][i][c][i][o][n][e][s] ) posiciones "${url_pos}" ;;
  [Rr][e][p][e][c][h][a][j][e] ) playoff "${url}" 1 "REPECHAJES" ;;
  [Gg][r][u][p][o] ) resultados_grupo "${url}" "$2" ;;
  [Oo][c][t][a][v][o][s] ) playoff "${url}" 5 "8° DE FINAL" ;;
  [Cc][u][a][r][t][o][s] ) playoff "${url}" 6 "4° DE FINAL" ;;
  [Ss][e][m][i] ) playoff "${url}" 7 "SEMIFINAL" ;;
  [Ff][i][n][a][l]) playoff "${url}" 8 "FINAL" ;;
  * ) ;;
esac

#===============================================================================

# Limpieza
rm /tmp/fixture.* 2> /dev/null
rm /tmp/posiciones.* 2> /dev/null

exit
