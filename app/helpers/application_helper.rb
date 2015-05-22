module ApplicationHelper
  def format_date_time(datetime)
    datetime.strftime 'on %A, %B %e, %Y at %l:%M %P'
  end

  def site_text name
    SiteText.where(name: name).first.try :text
  end
end
