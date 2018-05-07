module ArticleHelpers
  def href(article)
    return '' unless article
    URI.join(config[:endpoint], article.url).to_s
  end

  def first_paragraph_text(article)
    return '' unless article

    rendered = article.render(layout: false, keep_separator: false)
    tags = Nokogiri::HTML.parse(rendered).css('p')
    text = tags.map(&:text).find {|content| !content.empty? }
    text ? text.delete("\n") : article.title
  end

  def first_img_href(article)
    return '' unless article

    rendered = article.render(layout: false, keep_separator: false)
    img = Nokogiri::HTML.parse(rendered).css('img').first
    return nil unless img

    src = img.attribute("src").value
    URI.join(config[:endpoint], src).to_s
  end
end
