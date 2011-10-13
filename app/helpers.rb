helpers do
  def partial(template, options={})
    slim template, :layout=>false, :locals=>options
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