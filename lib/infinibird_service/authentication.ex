defmodule InfinibirdService.Authentication do
  def unauthorized_response(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(401, ~s[{"Error": "401 - nauthorized"}])
  end
end
