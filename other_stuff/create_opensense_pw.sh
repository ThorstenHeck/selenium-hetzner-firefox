## generate password in temporary items
title=temporary-password
vault=c4rb2q4ru5aztf6yw3b7yxmupy
op create item Password --title $title --vault $vault --generate-password >/dev/null 2>&1
root_pw=$(op get item $title --vault $vault --fields password)
root_pw_hash=$(htpasswd -bnBC 10 "" $root_pw | tr -d ':\n')
op delete item $title --vault $vault

op create item Password --title $title --vault $vault --generate-password >/dev/null 2>&1
ansible_pw=$(op get item $title --vault $vault --fields password)
ansible_pw_hash=$(htpasswd -bnBC 10 "" $ansible_pw | tr -d ':\n')    # | sed 's/$2y/$2a/''
op delete item $title --vault $vault


title=Opnsense-Root-User
vault=c4rb2q4ru5aztf6yw3b7yxmupy
if op get item $title --vault $vault >/dev/null 2>&1
then
    op delete item $title --vault $vault
fi
tmp=$(mktemp)
jq --arg user root \
    '( .fields[] | select(.name=="username")).value |= $user' login_tmpl_multiple_pw.json > "$tmp" && mv "$tmp" login.json
jq --arg pw $root_pw \
    '( .fields[] | select(.name=="password")).value |= $pw' login.json > "$tmp" && mv "$tmp" login.json
jq --arg name hash \
    '( .sections[].fields[].t ) |= $name' login.json > "$tmp" && mv "$tmp" login.json
jq --arg pw $root_pw_hash \
    '( .sections[].fields[].v ) |= $pw' login.json > "$tmp" && mv "$tmp" login.json
op create item --template=login.json Login --title $title --vault $vault --generate-password >/dev/null 2>&1

# ansible user
title=Ansible-User
vault=c4rb2q4ru5aztf6yw3b7yxmupy
if op get item $title --vault $vault >/dev/null 2>&1
then
    op delete item $title --vault $vault
fi
tmp=$(mktemp)
jq --arg user ansible \
    '( .fields[] | select(.name=="username")).value |= $user' login_tmpl_multiple_pw.json > "$tmp" && mv "$tmp" login.json
jq --arg pw $ansible_pw \
    '( .fields[] | select(.name=="password")).value |= $pw' login.json > "$tmp" && mv "$tmp" login.json
jq --arg name hash \
    '( .sections[].fields[].t ) |= $name' login.json > "$tmp" && mv "$tmp" login.json
jq --arg pw $ansible_pw_hash \
    '( .sections[].fields[].v ) |= $pw' login.json > "$tmp" && mv "$tmp" login.json
op create item --template=login.json Login --title $title --vault $vault --generate-password >/dev/null 2>&1

rm login.json

# echo 'bGludXhoaW50LmNvbQo=' | base64

# Write Hash to config.xml
# xq -x --arg pw $root_pw_hash --arg user root \
#     '( .opnsense.system.user[] | select(.name == $user) ).password |= $pw' archive/config.ssh.xml > config.ssh_tmp.xml

# xq -x --arg pw $ansible_pw_hash --arg user ansible \
#     '( .opnsense.system.user[] | select(.name == $user) ).password |= $pw' config.ssh_tmp.xml > config.ssh.xml

# xq -x --arg ssh_pub $ssh_pub --arg user ansible \
#     '( .opnsense.system.user[] | select(.name == $user) ).authorizedkeys |= $ssh_pub' config.ssh_tmp.xml > config.ssh.xml

# rm config.ssh_tmp.xml



# jq --arg user ansible \
#     '( .fields[] | select(.name=="username")).value |= $user' login_tmpl_multiple_pw.json > "$tmp" && mv "$tmp" login.json

# jq --arg name hash \
#     '( .sections[].fields[].t ) |= $name' login.json > "$tmp" && mv "$tmp" login.json

# jq --arg pw geheim \
#     '( .sections[].fields[].v ) |= $pw' login.json > "$tmp" && mv "$tmp" login.json

# op create item --template=login.json Login --title $title --vault $vault --generate-password >/dev/null 2>&1