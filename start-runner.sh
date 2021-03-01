#!/bin/bash

cleanup() {
  echo "$(date -u +'%Y-%m-%d %TZ') Removing runner..."

  while :; do
    # job実行中は待つ
    wait_worker

    # runner登録を解除
    ./actions-runner/config.sh remove --unattended --token $RUNNER_TOKEN

    if [ $? = 0 ]; then
      break
    fi
  done
}

wait_worker() {
  local count=0 # Runner.Workerが見つからなかった回数
  local retry_count=0 # Runner.Workerをチェックした回数

  while :; do
    retry_count=$((retry_count+1))

    pkill -0 Runner.Worker >/dev/null 2>&1
    if [ $? = 0 ]; then
      # Runner.Workerが見つかったらカウントリセット
      count=0
    else
      count=$((count+1))
    fi

    if [ $count = 10 ]; then
      # job実行状態ではないと判断
      break
    fi
    if [ $retry_count = 60 ]; then
      echo "$(date -u +'%Y-%m-%d %TZ') Waiting for Runner.Worker to exit..."
      retry_count=0
    fi

    sleep 1
  done
}

run_once() {
  while :; do
    # job実行したら以降のjobを実行しないように終了処理を始める
    pkill -0 Runner.Worker >/dev/null 2>&1
    if [ $? = 0 ]; then
      echo "$(date -u +'%Y-%m-%d %TZ') Found Runner.Worker, start cleanup."
      kill -INT $1
      break
    fi

    sleep 1
  done
}

trap 'cleanup; exit 0' INT TERM

self_pid=$$

if [ "$LOCAL_MODE" = "enable" ]; then
  sudo dockerd &

  api_endpoint=https://api.github.com/repos/$REPOSITORY_NAME/actions/runners/registration-token
  RUNNER_TOKEN=$(curl -sX POST -H "Authorization: token $GITHUB_ACCESS_TOKEN" $api_endpoint | jq -r '.token')
fi

repo_url=https://github.com/$REPOSITORY_NAME
./actions-runner/config.sh --unattended --url $repo_url --token $RUNNER_TOKEN --labels self-hosted,Linux,X64,$ADDITIONAL_LABEL,$GITHUB_RUN_ID

./actions-runner/run.sh &
run_sh_pid=$!

run_once $self_pid &

wait $run_sh_pid
