# docker
vim node.conf
```
[program:node]
user=root
directory=/work/bin
;command=/work/bin/cortex --rpc --rpcaddr 0.0.0.0 --viper
command=/work/bin/cortex --viper
autorestart=true
autostart=true
numprocs=1

redirect_stderr=true
stdout_logfile_backups=5
stdout_logfile=/root/.cortex/node.log
```
### rpc cmd
```
  --rpc                   Enable the HTTP-RPC server
  --rpcaddr value         HTTP-RPC server listening interface (default: "localhost")
  --rpcport value         HTTP-RPC server listening port (default: 8545)
  --rpcapi value          API's offered over the HTTP-RPC interface
```
