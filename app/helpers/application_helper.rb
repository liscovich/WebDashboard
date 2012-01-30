module ApplicationHelper
  def fetch_gameuser_by_hit_and_worker(hit_id, worker_id)
    hit  = Hit.where(:hitid=> hit_id).first
    am   = Authentication.mturk.where(:uid => worker_id).first
    return nil if am.nil? or hit.nil?

    hit.gameusers.where(:user_id=>am.user_id).first
  end

  def format_time(time)
    t = Time.parse(time.to_s)
    t.strftime("%Y-%m-%d %H:%M:%S")
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
