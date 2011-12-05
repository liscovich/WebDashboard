helpers do
  def display_decimal(sig, num)
    sprintf("%.#{sig}f", num)
  end

  def is_researcher
    session[:role]=='researcher'
  end

  def is_me?(u)
    u.id==session[:id]
  end

  def login_required
    flash_back "You must be logged in!" unless is_logged_in?
  end

  def current_user
    return nil unless is_logged_in?
    User.get session[:id]
  end

  def fetch_gameuser_by_hit_and_worker(hit_id, worker_id)
    hit  = Hit.first(:hitid=> hit_id)
    am   = Authmethod.first(:auth_id=>worker_id, :auth_type=>'mturk')
    return nil if am.nil? or hit.nil?

    Gameuser.first(:game_id=>hit.game_id, :user_id=>am.user_id)
  end

  def difftime(diff,resolution=1)
    res = { :year   => 24*60*60*30*365,
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
  
  def is_logged_in?
    !!session[:id]
  end
    
  def timeago(start,resolution=1)
    str = start.to_s
    return "" if str==""
    difftime(Time.now-Time.parse(str),resolution)
  end
  
  def format_time(time)
    t = Time.parse(time.to_s)
    t.strftime("%Y-%m-%d %H:%M:%S")
  end

  def root_url
    "#{request.host}#{(request.port!=80) ? ":#{request.port}" : ''}"
  end
  
  def random(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
    
  def partial(template, options={})
    slim template, :layout=>false, :locals=>options
  end

  def r_cache (key,options={})
    g = $r.get("cache_"+key)
    return Marshal.load(g) unless g.nil?        
    
    v = yield
    return if v.nil?
    
    m = Marshal.dump(v)
    $r.setex("cache_"+key,(options[:expiry] || 3600),m)
    v
  end
  
  def r_expire(key)
    $r.del("cache_"+key)
  end
  
  def r_expire_pattern(p)
    keys = $r.keys("cache_"+p)
    $r.multi do
      keys.each do |k|
        $r.del k
      end
    end
  end
    
  def css(*sources)
    sources.map do |s|
      if(s.is_a? Symbol)
        s = CSS[s]
      elsif(s.chars.first=='/')
        s = "/stylesheets#{s}" 
      end
      "<link type=\"text/css\" charset=\"utf-8\" media=\"screen\" rel=\"stylesheet\" href=\"#{s}?#{RESET_CACHE}\"></link>"
    end.join
  end
 
  def js(*sources)
    sources.map do |s|
      if(s.is_a? Symbol)
        s = JS[s]
      elsif(s.chars.first=="/")
        s = "/javascripts#{s}?#{RESET_CACHE}"
      end
      join_char = if s.index('?').nil? then '?' else '&' end
      "<script src=\"#{s}#{join_char}#{RESET_CACHE}\" type=\"text/javascript\" charset=\"utf-8\"></script>"
    end.join
  end

  def content_for(key, &block)
    content_blocks[key.to_sym] << block
    ''
  end
 
  def yield_content(key, *args)
    content_blocks[key.to_sym].map do |content|      
      content.call(*args)      
    end.uniq.join
  end
  
  def redirect_flash(url,type,msg)
    flash[type]=msg
    redirect url
  end
  
  def flash_back(msg)
    redirect_flash back, :error, msg
  end
  
  private
    def content_blocks
      @content_blocks ||= Hash.new {|h,k| h[k] = [] }
    end      
end