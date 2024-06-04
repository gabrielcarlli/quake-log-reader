module UploadsHelper
  DEATH_CAUSE_MAPPER = {
    'MOD_UNKNOWN' => 'Doing something mysterious',
    'MOD_SHOTGUN' => 'Shotgun',
    'MOD_GAUNTLET' => 'Gauntlets',
    'MOD_MACHINEGUN' => 'Machine gun',
    'MOD_GRENADE' => 'Grenade Launcher',
    'MOD_GRENADE_SPLASH' => "Grenade Launcher's splash damage",
    'MOD_ROCKET' => 'Direct rocket to the face',
    'MOD_ROCKET_SPLASH' => "Rocket splash damage",
    'MOD_PLASMA' => 'Plasma Gun',
    'MOD_PLASMA_SPLASH' => "Plasma gun's splash damage",
    'MOD_RAILGUN' => 'Railgun',
    'MOD_LIGHTNING' => 'Lightning Gun',
    'MOD_BFG' => 'BFG10K',
    'MOD_BFG_SPLASH' => "BFG10K's splash damage",
    'MOD_WATER' => 'Drowning in water',
    'MOD_SLIME' => 'Melting in slime',
    'MOD_LAVA' => 'Swimming in lava',
    'MOD_CRUSH' => 'Liking high pressures',
    'MOD_TELEFRAG' => 'Telefragged',
    'MOD_FALLING' => 'Spontaneus vertical deacceleration',
    'MOD_SUICIDE' => 'Ended their own life',
    'MOD_TARGET_LASER' => 'Following lasers',
    'MOD_TRIGGER_HURT' => 'Not watching their step',
    'MOD_NAIL' => 'Stepping on a nail',
    'MOD_CHAINGUN' => 'Chaingun',
    'MOD_PROXIMITY_MINE' => 'Proximity Mine',
    'MOD_KAMIKAZE' => 'Doing the kamikaze',
    'MOD_JUICED' => 'Getting juiced',
    'MOD_GRAPPLE' => 'Grappling Hook'
  }.freeze

  WEAPON_NAME_MAPPER = {
    'MOD_TELEFRAG' => 'Telefragging',
    'MOD_SHOTGUN' => 'Shotgun',
    'MOD_GAUNTLET' => 'Gauntlets',
    'MOD_MACHINEGUN' => 'Machine gun',
    'MOD_GRENADE' => 'Grenade Launcher',
    'MOD_GRENADE_SPLASH' => "Grenade Launcher",
    'MOD_ROCKET' => 'Rocket Launcher',
    'MOD_ROCKET_SPLASH' => "Rocket Launcher",
    'MOD_PLASMA' => 'Plasma Gun',
    'MOD_PLASMA_SPLASH' => "Plasma Gun",
    'MOD_RAILGUN' => 'Railgun',
    'MOD_LIGHTNING' => 'Lightning Gun',
    'MOD_BFG' => 'BFG10K',
    'MOD_BFG_SPLASH' => "BFG10K",
    'MOD_CHAINGUN' => 'Chaingun',
    'MOD_PROXIMITY_MINE' => 'Proximity Mine',
    'MOD_GRAPPLE' => 'Grappling Hook'
  }.freeze

  def self.parse_log(log)
    matches = log.split('InitGame')
    matches.shift
    mount_parsed_jsons(matches)
  end

  def self.mount_parsed_jsons(matches)
    response = {}

    matches.each_with_index do |round, i|
      key = "game_#{i + 1}"

      players = round.scan(/n\\(.*?)\\t/).uniq.flatten.sort
      all_kills = round.scan(/(\w+|<\w+>)\s+killed\s+(.*)\s+by\s+(.*)/)
      kill_info = round_kill_info(all_kills)

      response[key] =
        {
          players: players,
          total_kills: kill_info[:player_kills],
          total_deaths: kill_info[:death_count],
          world_deaths: kill_info[:world_kills],
          player_info: player_statistics(all_kills, players, round)
        }

      mvp_candidate = response[key][:player_info].max_by { |_k, v| v[:final_score] }
      response[key][:mvp] = mvp_candidate[1][:final_score] > 0 ? mvp_candidate[0] : 'No MVP'
    end

    response
  end

  def self.round_kill_info(all_kills)
    {
      death_count: all_kills.size,
      world_kills: all_kills.select { |kill| kill[0] == '<world>' }.size,
      player_kills: all_kills.reject { |kill| kill[0] == '<world>' }.size
    }
  end

  def self.player_statistics(kills, players, round)
    player_info = {}

    players.each do |player|
      player_kills = kills.select { |kill| kill[0] == player }
      kills_without_self = player_kills.reject { |kill| kill[2] == player }
      player_deaths = kills.select { |kill| kill[1] == player }
      player_world_deaths = kills.select { |kill| kill[0] == '<world>' && kill[2] == player }

      player_info[player] = {
        kills: kills_without_self.size,
        deaths: player_deaths.size,
        world_deaths: player_world_deaths.size,
        final_score: player_kills.size - player_world_deaths.size,
        extra_details: extra_details(kills_without_self, player_deaths)
      }
    end

    player_info
  end

  def self.extra_details(kills, deaths)
    response = {
      kills_per_weapon: {},
      death_causes: {},
      self_deaths: deaths.select { |death| death[0] == death[1] }.size,
      favourite_weapon: 'None'
    }

    kill_methods = kills.map { |kill| kill[2] }.uniq
    death_methods = deaths.map { |death| death[2] }.uniq

    death_methods.each do |death|
      key = DEATH_CAUSE_MAPPER[death] || death
      response[:death_causes][key] = deaths.select { |d| d[2] == death }.size
    end
    response[:death_causes] = response[:death_causes].sort_by { |_, v| -v }.to_h

    kill_methods.each do |kill|
      key = WEAPON_NAME_MAPPER[kill] || kill
      response[:kills_per_weapon][key] ||= 0
      response[:kills_per_weapon][key] += kills.select { |k| k[2].downcase == kill.downcase }.size
    end
    response[:kills_per_weapon] = response[:kills_per_weapon].sort_by { |_, v| -v }.to_h

    if kills.count.positive?
      response[:favourite_weapon] = response[:kills_per_weapon].max_by { |_w, count| count }.first
    end

    response
  end
end
