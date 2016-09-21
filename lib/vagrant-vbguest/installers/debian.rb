module VagrantVbguest
  module Installers
    class Debian < Linux

      def self.match?(vm)
        /\Adebian\d*\Z/ =~ self.distro(vm)
      end

      # installs the correct linux-headers package
      # installs `dkms` package for dynamic kernel module loading
      # @param opts [Hash] Optional options Hash which might get passed to {Vagrant::Communication::SSH#execute} and friends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def install(opts=nil, &block)
        communicate.sudo('apt-get update', opts, &block)
        communicate.sudo(install_dependencies_cmd, opts, &block)
        super
      end

    protected
      def install_dependencies_cmd
        "apt-get install -y #{dependencies}"
      end

      def dependencies
        packages = ['linux-headers-`uname -r`']
        # some Debian system (lenny) don't come with a dkms package so we need to skip that.
        # apt-cache search will exit with 0 even if nothing was found, so we need to grep.
        packages << 'dkms' if communicate.test('apt-cache search --names-only \'^dkms$\' | grep dkms')
        packages.join ' '
      end
    end
  end
end
VagrantVbguest::Installer.register(VagrantVbguest::Installers::Debian, 5)
