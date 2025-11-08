class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.4.5.tar.gz"
  sha256 "311a7a3fb39cfbf478bd0a9ac2c6b5cc5fc509383edad223b119ec89f7ef66b5"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/slickag/scoop"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "9e0ad2df306742adc0e2deedd4119560e616008a56954f26efe04eef4b52d30f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "2484e19ef16be970bf9693ca70fd282b33b07c54bbb55c89bae37eb8c0bc2422"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "5aea8c9009e1472abd538f46310a77e378b443753bd32c8588f9cdf01be8fb20"
    sha256 cellar: :any_skip_relocation, sequoia:       "82356441cfe58c16ac9c0d41e6311260fe1fc33e16ad25fae6a403e9fe3b0289"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "9d72ceec9040957c4b8233b5cd02530c2cd96a947ecebf56d2a9a8148d4ca9ef"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ae6595a4bb1a3cd9fb7aea4968f82395d4d5b85b1bb7018d8e667abdebb609cb"
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-trimpath", *std_go_args(ldflags: "-s -w")
  end

  test do
    require "pty"
    require "expect"
    require "io/console"
    timeout = 30

    PTY.spawn("#{bin}/taproom --hide-columns Size") do |r, w, pid|
      r.winsize = [80, 130]
      begin
        refute_nil r.expect("Loading all Casks", timeout), "Expected cask loading message"
        w.write "q"
        r.read
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      ensure
        r.close
        w.close
        Process.wait(pid)
      end
    end
  end
end
