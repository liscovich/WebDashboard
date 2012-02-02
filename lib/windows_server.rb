class WindowsServer
  IP = "50.57.141.31"
  SERVER_IP   = "#{IP}:4567"
  PHOTON_PORT = "5055"
  
  class << self
    def start_master_client!(game)
      uri   = URI("http://#{SERVER_IP}/new")
      param = "-session=#{game.id}" <<
        " -server=#{IP}:#{PHOTON_PORT}"  <<
        " -totalPlayers=#{game.totalplayers}" <<
        " -humanPlayers=#{game.humanplayers}" <<
        " -probability=#{game.contprob}" <<
        " -initialEndowments=#{game.init_endow}" <<
        " -payout=#{game.ind_payoff_shares}" <<
        " -cardLowValue=#{game.cost_defect}" <<
        " -cardHighValue=#{game.cost_coop}"  <<
        " -exchangeRate=#{game.exchange_rate} -batchmode"

      res = Net::HTTP.post_form(uri, 'id' => game.id, 'instance' => 'test', 'args' => param)

      unless res.code == "200"
        game.destroy
        Rail.logger.error(res.body)
        raise "Cannot not start up master client!"
      end

      #uri = URI("http://#{WindowsServer::SERVER_IP}/instance/#{g.id}.unity3d")
      #res = Net::HTTP.get(uri)

      #File.open(ROOT+"/../public/flash/webplayer.unity3d", "wb") do |file|
      #  file.write(res)
      #end
    end

    def delete_all_instances
      uri = URI("http://#{SERVER_IP}/instance/delete_all")
      Net::HTTP.get(uri)
    end

    def unity_player_url(game)
      raise "game isn't assigned" unless game

      "http://#{SERVER_IP}/instance/#{game.id}.unity3d"
    end

    def params_for_unity(game, user)
      "#{game.id}" + "|" + "#{IP}" + "|" + "#{PHOTON_PORT}" + "|" + "#{user.id}" + "|" + "false"
    end
  end
end
