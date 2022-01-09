#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#===============================================================================

playoff () { 
  url="$1"
  fase_ini="$2"
  fase_fin="$(expr "${fase_ini}" + 1)"
  nombre_fase="$3"

  tmp="/tmp/fixture.tmp"
  tmp2="/tmp/fixture.tmp2"
  tmp_utf="/tmp/fixture.tmp.utf8"
  tmp_html="/tmp/fixture.html"
  tmp_html2="/tmp/fixture.html2"

#-------------------------------------------------------------------------------

  rm /tmp/fixture.* 2> /dev/null
  wget -O "${tmp}" -c -nv "${url}" 2> /dev/null 

  regex="armscii8|big5(hkscs)?|cp125[1-5]|euc(jp|kr|tw)|gb(18030|2312|k)|georgianps|iso8859[1-9][0-5]?|koi8[rtu]|pt154|tis620|utf-?8|tcvn57121|rk1048"
  codificacion="$(locale | grep -E -i -o "${regex}" | sort -u)"
  iconv -f latin1 -t "${codificacion}" "${tmp}" -o "${tmp_utf}"

  sed 's/ show//g' "${tmp_utf}" > "${tmp}"
  sed -n '/<div class="fase n'"${fase_ini}"' col-md-12 ">/,/<div class="fase n'"${fase_fin}"' col-md-12 ">/p' "${tmp}" | tr "&" " " > "${tmp2}"
  sed 's/<\/img>//g' "${tmp2}" | sed 's/<img src//g' | sed 's/ nbsp;/-/g' | \
    sed 's/ e_[0-9]*//g' | sed '/<div class="footerCtn">/d' | sed '/<div class="fase n'"${fase_fin}"'/d' > "${tmp_html}"

#-------------------------------------------------------------------------------

  if [[ "$2" -gt 5 ]]; then
      sed '1c<div><div><div><div><div><div>\n' "${tmp_html}" > "${tmp_html2}"
  else
      sed '1c<div><div><div>\n' "${tmp_html}" > "${tmp_html2}"
  fi

  mv "${tmp_html2}" "${tmp_html}"

#-------------------------------------------------------------------------------

  parseador="xpath -q -e '%s' "${tmp_html}" | sed -E 's/Ã¡/á/g; s/Ã­/í/g; s/Ã³/ó/g; s/Ã©/é/g; s/Ãº/ú/g; s/Ã±/ñ/g; s/Ãª/ê/g; s/Ã£/ã/g' | tr "'" " "_"'
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

  red="\033[1;31m"
  blue="\033[1;34m"
  bold="\033[1m"
  def="\033[0m"
  cyan="\033[1;36m"
  green="\033[1;32m"
  orange="\033[1;33m"
  black="\033[1;30m"

  header="| %-""${ancho_local}""s [ %-1s ] %-2s [ %-1s ] %-""${ancho_visitante}""s | %-10s | %-7s |\n"
  content="| ${red}%-""$ancho_local""s${def} [ ${red}%-1s${def} ] %-2s [ ${blue}%-1s${def} ] ${blue}%-""$ancho_visitante""s${def} | %-10s | %-7s |\n"
  fmt_header=("LOCAL" "-" "vs" "-" "VISITANTE" "DIA" "HORA")
  char="$(bc -l <<< "$(printf "${header}" "${fmt_header[@]}" | wc -c) - 1")"

#-------------------------------------------------------------------------------

  printf "\n${orange}%40s${def}\n" "${nombre_fase}"

  for (( i=0; i<"${cant_partidos}"; i++ )); do
    let j="$(( ("$i" / 2) + 1 ))"

    if [[ "$(( "$i" % 2 ))" -eq 0 ]]
    then
      printf "\n${cyan}%35s${def}\n" """Llave  $j"
      printf "%${char}s\n" | tr " " -
      printf "${header}" "${fmt_header[@]}"
      printf "%${char}s\n" | tr " " -
    fi

    awk 'BEGIN {
      printf "'"${content}"'", "'"${local[$i]//_/ }"'", "'${gol_local[$i]}'", \
      "vs", "'${gol_visita[$i]}'", "'"${visita[$i]//_/ }"'", "'${dias[$i]}'", "'"${horas[$i]//_/ }"'"
    }'

  done

  printf "\n"
}

#===============================================================================

url="http://estadisticas-deportes.tycsports.com/html/v3/htmlCenter/data/deportes/futbol/sudamericana/pages/es/fixture.html"

#===============================================================================

case "$1" in
  [Rr][e][p][e][c][h][a][j][e] ) playoff "${url}" 1 "REPECHAJES" ;;
  [1][6][a][v][o][s] ) playoff "${url}" 2 "16° DE FINAL" ;;
  [Oo][c][t][a][v][o][s] ) playoff "${url}" 3 "8° DE FINAL" ;;
  [Cc][u][a][r][t][o][s] ) playoff "${url}" 4 "4° DE FINAL" ;;
  [Ss][e][m][i] ) playoff "${url}" 5 "SEMIFINAL" ;;
  [Ff][i][n][a][l]) playoff "${url}" 6 "FINAL" ;;
  * ) ;;
esac

#===============================================================================

# Limpieza
rm /tmp/fixture.* 2> /dev/null

exit
