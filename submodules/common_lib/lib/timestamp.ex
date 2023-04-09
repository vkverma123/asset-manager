defmodule CommonLib.Timestamp do
  def now do
    DateTime.utc_now()
  end

  def date_now do
    Date.utc_today()
  end
end
