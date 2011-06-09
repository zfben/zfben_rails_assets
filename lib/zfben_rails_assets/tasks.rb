def p str
  STDOUT.puts str.color(:black).background(:white)
end

def sys cmd
  p cmd
  system cmd
end

def err msg
  STDOUT.puts msg.color(:yellow).background(:red)
  exit!
end

namespace :assets do
  task :clear_assets do
    p 'Clear old assets'
    js_path = File.join(Rails.root, 'app', 'assets', 'javascripts', 'zff')
    css_path = File.join(Rails.root, 'app', 'assets', 'stylesheets', 'zff')
    img_path = File.join(Rails.root, 'app', 'assets', 'images', 'zff')
    sys('rm -r ' + js_path) if File.exists?(js_path)
    sys('rm -r ' + css_path) if File.exists?(css_path)
    sys('rm -r ' + img_path) if File.exists?(img_path)
  end
  
  desc 'add assets files to app/assets'
  task :add_assets => :clear_assets do
    p 'Add assets'
    sys 'cp -Ruf ' << File.join(ZfbenRailsAssetsPath, 'assets') << ' ' << File.join(Rails.root, 'app')
  end
  
  task :clear_config do
    p 'Clear old config'
    config_path = File.join(Rails.root, 'config', 'compass.rb')
    sys('rm ' + config_path) if File.exists?(config_path)
  end
  
  desc 'add config files to config'
  task :add_config => :clear_config do
    p 'Add config'
    sys 'cp -Ruf ' << File.join(ZfbenRailsAssetsPath, 'config', 'compass.rb') << ' ' << File.join(Rails.root, 'config')
  end
  
  task :clear_gem do
    gem_path = File.join(Rails.root, 'Gemfile')
    unless File.exists? gem_path
      err 'Gemfile is not exists'
    else
      p 'Clear old gems'
      file = File.open(gem_path).readlines.join('')
      regexp = /(\n)?# Added by zfben_rails_assets.*# End zfben_rails_assets/im
      File.open(gem_path, 'w'){ |f| f.write(file.gsub(regexp, '')) } if file =~ regexp
    end
  end
  
  desc 'add Gemfile'
  task :add_gem => :clear_gem do
    p 'Add gems'
    gem_path = File.join(Rails.root, 'Gemfile')
    file = File.open(gem_path).readlines
    file.push "\n# Added by zfben_rails_assets\n\n" << File.open(File.join(ZfbenRailsAssetsPath, 'Gemfile')).readlines.join('') << "\n# End zfben_rails_assets"
    File.open(gem_path, 'w'){ |f| f.write(file.join('')) }
  end
  
  desc 'install zfben_rails_assets'
  task :install => [:add_gem, :add_config, :add_assets] do
    sys 'bundle install'
  end
  
  desc 'uninstall zfben_rails_assets'
  task :uninstall => [:clear_gem, :clear_config, :clear_assets]
end