class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v13.0.2/forgejo-src-13.0.2.tar.gz"
  sha256 "6731d5e73a025c1a04aba0f84caf80886d5be0031f4c154ac63026e7fe30918a"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/slickag/scoop"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d0b6ef7d67c6fe53dca0c77cc6e814f9be9aa59a643dc81c3d698ac54851d974"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e23f776fbc2f183c36255a6f6c20480a6f78f40a88026e2525fa12ec58b7512f"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "8cce3835f6e491ac4344514f6743f8a0214215c6525357fd7c6f903c4082c825"
    sha256 cellar: :any_skip_relocation, sequoia:       "a775e2f52a3cc68feca05093fca5d424a279a5527d4198530f06a796f31da06b"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "5d57ae33c664d18327116a8ab9856a3df2f6d7466fd1b928b143e0bbaea9cda8"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "47a9887811ad7f25ec82de49a14d1ab816434250bf3779588b938e9ff8d1e5f7"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  uses_from_macos "sqlite"

  def install
    ENV["CGO_ENABLED"] = "1"
    ENV["TAGS"] = "bindata timetzdata sqlite sqlite_unlock_notify"
    system "make", "build"
    system "go", "build", "contrib/environment-to-ini/environment-to-ini.go"
    bin.install "gitea" => "forgejo"
    bin.install "environment-to-ini"
  end

  service do
    run [opt_bin/"forgejo", "web", "--work-path", var/"forgejo"]
    keep_alive true
    log_path var/"log/forgejo.log"
    error_log_path var/"log/forgejo.log"
  end

  test do
    ENV["FORGEJO_WORK_DIR"] = testpath
    port = free_port

    pid = fork do
      exec bin/"forgejo", "web", "--port", port.to_s, "--install-port", port.to_s
    end
    sleep 5
    sleep 10 if OS.mac? && Hardware::CPU.intel?

    output = shell_output("curl -s http://localhost:#{port}/api/settings/api")
    assert_match "Go to default page", output

    output = shell_output("curl -s http://localhost:#{port}/")
    assert_match "Installation - Forgejo: Beyond coding. We Forge.", output

    assert_match version.to_s, shell_output("#{bin}/forgejo -v")
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
