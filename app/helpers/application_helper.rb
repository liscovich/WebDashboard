module ApplicationHelper
  def fetch_gameuser_by_hit_and_worker(hit_id, worker_id)
    hit  = Hit.where(:hitid=> hit_id).first
    am   = Authentication.where(:uid => worker_id, :provider => 'mturk').first
    return nil if am.nil? or hit.nil?

    Gameuser.where(:game_id=>hit.game_id, :user_id=>am.user_id).first
  end

  def difftime(diff,resolution=1)
    res = { :year => 24*60*60*30*365,
      :month  => 24*60*60*30,
      :day    => 24*60*60,
      :hour   => 60*60,
      :minute => 60,
      :second => 1}

    count = 0
    str   = ''
    res.each do |name,thres|
      if(diff>=thres)
        val = (diff/thres).floor
        if(count>0)
          str+=" "
        end
        str+="#{val} #{name}"
        if(val>1)
          str+="s"
        end
        diff-=val*thres
        count+=1
      end
      if count>=resolution
        break
      end
    end
    if(str.length==0)
      str="1 second"
    end
    str.strip
  end

  def format_time(time)
    t = Time.parse(time.to_s)
    t.strftime("%Y-%m-%d %H:%M:%S")
  end

  def random(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    newpass
  end

  #TODO recheck
  def r_cache(key,options={})
    g = $r.get("cache_"+key)
    return Marshal.load(g) unless g.nil?

    v = yield
    return if v.nil?

    m = Marshal.dump(v)
    $r.setex("cache_"+key,(options[:expiry] || 3600),m)
    v
  end

  #TODO recheck
  def r_expire(key)
    $r.del("cache_"+key)
  end

  #TODO recheck
  def r_expire_pattern(p)
    keys = $r.keys("cache_"+p)
    $r.multi do
      keys.each do |k|
        $r.del k
      end
    end
  end

  # TODO remove
  def css(*sources)
    sources.map do |s|
      stylesheet_link_tag(s.is_a?(Symbol) ? CSS[s] : s)
    end.join.html_safe
  end

  # TODO remove
  def js(*sources)
    sources.map do |s|
      javascript_include_tag(s.is_a?(Symbol) ? JS[s] : s)
    end.join.html_safe
  end
end
