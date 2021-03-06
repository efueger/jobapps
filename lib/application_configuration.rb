module ApplicationConfiguration
  # Accepts an array of symbols corresponding to the key path
  # at which to reach the desired value in application.yml.
  # For instance [:a, :b] would query CONFIG[:a][:b].
  # Optionally, although most of the time, accepts an options
  # hash containing a default value in the case where one is not
  # configured.
  def configured_value(config_path, options = {})
    value = CONFIG
    config_path.each do |key|
      value = value[key]
    end
    if value.present?
      value
    elsif options[:default].present?
      options[:default]
    else
      raise ArgumentError,
            "Configuration behavior #{config_path} not configured
            and default not specified."
    end
  end
end
