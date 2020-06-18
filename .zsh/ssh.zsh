# port forwarding
function pf() {
  ssh -D1080 -N -f $1 >& /dev/null
}
compdef _host pf
function pfkill() {
  pf_pid=$(ps -ef | grep "ssh -D1080 -N -f $1" | grep -v grep | awk '{print $2}')
  kill $pf_pid
}
compdef _host pfkill

# ssh-agent
SSH_AGENT_FILE="${HOME}/.ssh/ssh_agent"
AGENT_ADD_DIR="${HOME}/.ssh/agent_add"

if command -v ssh-agent 1>/dev/null 2>&1; then
  # 固定化された ssh-agent 設定が存在すれば、それを読み込んで
  # 既に起動している ssh-agent プロセスを再利用
  [ -f $SSH_AGENT_FILE ] && source $SSH_AGENT_FILE >& /dev/null

  # ssh-agent プロセスが存在しないならば、これを起動しつつ、設定をファイルに出力
  if [ -d $HOME/.ssh ] && [ $( ps -ef | grep ssh-agent | grep -v grep | wc -l ) -eq 0 ]; then
    ssh-agent >| $SSH_AGENT_FILE
    # ssh-agent の設定内容を標準出力してほしいなら、/dev/null へ投げなくても良い
    source $SSH_AGENT_FILE >& /dev/null
    # $AGENT_ADD_DIR 配下にある id_rsa という名前のファイルを ssh-add
    [ -d $AGENT_ADD_DIR ] && find $AGENT_ADD_DIR -name id_rsa | xargs ssh-add >& /dev/null
  fi
fi