class Aria2 < Formula
  desc "Download with resuming and segmented downloading"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0.tar.xz"
  sha256 "60a420ad7085eb616cb6e2bdf0a7206d68ff3d37fb5a956dc44242eb2f79b66b"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/slickag/scoop"
    rebuild 2
    sha256 cellar: :any,                 arm64_tahoe:   "ee7b297593b3c457d4722405bd35f81f24b070bf37ea6745ab5116e797f2c0d3"
    sha256 cellar: :any,                 arm64_sequoia: "e55d1635ce4e4137f9a98091cb3b0428a5bcf8b5087179289daf5155f5bf7dc8"
    sha256 cellar: :any,                 arm64_sonoma:  "93f6f0fc274958a0c9943c677086f4c2b1880fb5b84beda823569f9957a379c5"
    sha256 cellar: :any,                 sequoia:       "9ce3e24fe9c332a0357f747cc67c6820de27a9f1145373739966dd529db42970"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "b95bade855c44f91b1489e879ce0face858a433cce901c4a852aa5a25d03c138"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "8f6d0e4d702395615ddb5d10776cf3687723117f3e486746ebde6e085582c94d"
  end

  head do
    url "https://github.com/aria2/aria2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkgconf" => :build

  depends_on "c-ares"
  depends_on "libssh2"
  depends_on "sqlite"

  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "openssl@3"
  end

  def install
    ENV.cxx11

    if build.head?
      ENV.append_to_cflags "-march=native -O3 -pipe -flto=auto"

      system "autoreconf", "--force", "--install", "--verbose"
    end

    args = %w[
      --disable-silent-rules
      --disable-nls
      --enable-metalink
      --enable-bittorrent
      --with-libcares
      --with-libssh2
      --with-libxml2
      --with-libz
      --without-gnutls
      --without-libgcrypt
      --without-libgmp
      --without-libnettle
    ]
    if OS.mac?
      args << "--with-appletls"
      args << "--without-openssl"
    else
      args << "--without-appletls"
      args << "--with-openssl"
    end

    system "./configure", *args, *std_configure_args
    system "make", "install"

    bash_completion.install "doc/bash_completion/aria2c"
  end

  test do
    system bin/"aria2c", "https://brew.sh/"
    assert_path_exists testpath/"index.html", "Failed to create index.html!"
  end
end
