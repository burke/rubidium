require 'metric_fu'

MetricFu::Configuration.run do |config|
  #define which metrics you want to use
  config.metrics  = [:churn, :saikuro, :flog, :flay, :reek, :roodi]
  config.flay     = { :dirs_to_flay => ['app', 'lib']  } 
  config.flog     = { :dirs_to_flog => ['app', 'lib']  }
  config.reek     = { :dirs_to_reek => ['app', 'lib']  }
  config.roodi    = { :dirs_to_roodi => ['app', 'lib'] }
  config.saikuro  = { :output_directory => 'scratch_directory/saikuro', 
    :input_directory => ['app', 'lib'],
    :cyclo => "",
    :filter_cyclo => "0",
    :warn_cyclo => "5",
    :error_cyclo => "7",
    :formater => "text"} #this needs to be set to "text"
  config.churn    = { :start_date => "1 year ago", :minimum_churn_count => 10}
end
