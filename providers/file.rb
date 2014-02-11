action :enable do
  # setup a swap file that we can use
  if %{ debian fedora rhel }.include? node[:platform_family]
    path = new_resource.path
    size = new_resource.size

    size =~ /(\d+)(.*)/

    size = $1
    unit = $2

    kibibytes = size.to_i * case unit.downcase
                            when 'mb', 'm'
                              1024
                            when 'gb', 'g'
                              1024 * 1024
                            end

    bash "create swap file #{path}" do
      code <<-EOB
        dd if=/dev/zero of=#{path} bs=1024 count=#{kibibytes}
      EOB

      action :run

      not_if { ::File.exists? path }
    end

    bash "create the swap filesystem on #{path}" do
      action :run

      code <<-EOB
        mkswap #{path}
      EOB

      not_if { ::IO.popen("file -b #{path}").readlines.first =~ /swap file/ }
    end

    bash "enable swap file #{path}" do
      code <<-EOB
        swapon #{path}
      EOB

      action :run

      not_if { ::IO.popen('swapon -s').readlines.any? {|line| line.start_with? path} }
    end
  end
end

action :disable do
  # setup a swap file that we can use
  if %{ debian fedora rhel }.include? node[:platform_family]
    path = new_resource.path

    bash "disable swap file #{path}" do
      code <<-EOB
        swapoff #{path}
      EOB

      action :run

      only_if { ::IO.popen('swapon -s').readlines.any? {|line| line.start_with? path} }
    end
  end
end
