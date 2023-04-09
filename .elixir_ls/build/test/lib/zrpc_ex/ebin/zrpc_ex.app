{application,zrpc_ex,
             [{applications,[kernel,stdlib,elixir,logger,ecto,hackney,jason,
                             opentelemetry_tesla,plug_cowboy,tesla]},
              {description,"zrpc_ex"},
              {modules,['Elixir.ZrpcEx','Elixir.ZrpcEx.Client',
                        'Elixir.ZrpcEx.Client.StatusNotOkError',
                        'Elixir.ZrpcEx.Client.TimeoutError',
                        'Elixir.ZrpcEx.Client.UnhandledError',
                        'Elixir.ZrpcEx.Handler']},
              {registered,[]},
              {vsn,"0.1.0"}]}.