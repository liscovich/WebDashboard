helpers do
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
  
  private
    def content_blocks
      @content_blocks ||= Hash.new {|h,k| h[k] = [] }
    end      
end