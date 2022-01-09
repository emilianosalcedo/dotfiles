#!/bin/sh

conf="${XDG_CONFIG_HOME}/tmux/tmux.conf"
cols="$(tput cols)"
rows="$(tput lines)"
session="master"
wone="main"
wtwo="files"
wthree="calendario"
wfour="monitor"
wfive="audio"
wsix="music"
wseven="remotos"
weight="dev"
wnine="doc"
command_one="$(xdg-user-dir PICTURES)/screenshots/"
command_two="$(xdg-user-dir VIDEOS)/screencasts/"
command_three="~/eduqueo/"
command_four="/tmp/"
command_five="~/projects/repositorios/eduqueo/"
command_six="~/Dropbox/11\ -\ WIKI\ SISTEMAS/WIKI\ SISTEMAS\ EDUQUEO/"
cal_opts="--confdir ${XDG_CONFIG_HOME}/calcurse/ --datadir ${XDG_CONFIG_HOME}/calcurse/"

tmux has-session -t ${session} >/dev/null 2>&1

if [ $? = 1 ]; then
  tmux -f "${conf}" new-session -s ${session} -d -x ${cols} -y ${rows} \; \
    rename-window -t ${session}:1 ${wone} \; \
    split-window -v -t ${wone} \; \
    new-window -n ${wtwo} "ranger" \; \
    new-window -n ${wthree} "calcurse ${cal_opts}" \; \
    new-window -n ${wfour} "bpytop" \; \
    new-window -n ${wfive} "pulsemixer" \; \
    new-window -n ${wsix} "ncmpcpp" \; \
    new-window -n ${wseven} \; \
      split-window -v \; \
      split-window -h \; \
      select-pane -t 1 \; \
      split-window -h \; \
      select-pane -t 1 \; \
    new-window -n ${weight} \; \
      split-window -v -p 20 \; \
      resize-pane -D 16 \; \
      select-pane -t 1 \; \
    new-window -n ${wnine} \; \
    select-window -t ${session}:${wone} \; \
    select-pane -t 1

  tmux send-keys -t ${session}:${wone}.2 " rivadavia" C-l
  tmux send-keys -t ${session}:${wseven}.1 " cd ${command_one}" C-m C-l
  tmux send-keys -t ${session}:${wseven}.2 " cd ${command_two}" C-m C-l
  tmux send-keys -t ${session}:${wseven}.3 " cd ${command_three}" C-m C-l
  tmux send-keys -t ${session}:${wseven}.4 " cd ${command_four}" C-m C-l
  tmux send-keys -t ${session}:${wseven}.1 " ebano2" C-l
  tmux send-keys -t ${session}:${wseven}.2 " colibri2" C-l
  tmux send-keys -t ${session}:${wseven}.3 " dinamarca2" C-l
  tmux send-keys -t ${session}:${wseven}.4 " stripe" C-l
  tmux send-keys -t ${session}:${weight}.1 " cd ${command_five}" C-m C-l
  tmux send-keys -t ${session}:${weight}.2 " cd ${command_five}" C-m C-l
  tmux send-keys -t ${session}:${weight}.1 " ll" C-l C-m
  tmux send-keys -t ${session}:${wnine}.1 " cd ${command_six}" C-m C-l
  tmux send-keys -t ${session}:${wnine}.1 " ll" C-l C-m
  tmux resize-pane -t ${session}:${weight}.2 -y 8
fi

[ $? = 0 ] && tmux attach -t ${session}
