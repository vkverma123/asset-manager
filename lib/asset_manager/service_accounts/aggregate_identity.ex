defprotocol AssetManager.ServiceAccounts.AggregateIdentity do
  @spec identity(any) :: String.t()
  def identity(_)
end
