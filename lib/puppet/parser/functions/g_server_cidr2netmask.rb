module Puppet::Parser::Functions
  newfunction(:g_server_cidr2netmask, type: :rvalue) do |args|
    unless args.length == 1
      raise Puppet::ParseError, "g_server_cidr2netmask(): wrong number of arguments (#{args.length}; must be 1)"
    end

    IPAddr.new('255.255.255.255', Socket::AF_INET).mask(args[0].to_i).to_s
  end
end
