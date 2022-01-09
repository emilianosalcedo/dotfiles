#!/bin/sh

printf "File Name: "

while [ -z "${ans}" ]; do
  read -r ans

  if [ -z "${ans}" ]; then
    printf "File Name: "
  fi
done

file="${HOME}/.local/bin/${ans}"

if [ -d "${HOME}/.local/bin" ]; then
  if [ -e "${HOME}/.local/bin/${ans}" ]; then
    ${EDITOR} "${file}"
  else
    printf "%s\n\n" "#!/bin/sh" >> "${file}"
    chmod 755 "${file}"
    ${EDITOR} "${file}"
  fi
fi
