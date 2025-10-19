#!/bin/bash

# =============================
#          SETUP SCRIPT
# =============================

# Lấy thư mục chứa script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Sao chép các file cấu hình
echo "Đang sao chép file cấu hình cá nhân..."
cp -rf "$SCRIPT_DIR/.config" $HOME/
cp -rf "$SCRIPT_DIR/Pictures" $HOME/
echo "Hoàn tất sao chép."

cd $HOME

# Cập nhật hệ thống trước khi cài đặt
echo "Đang cập nhật hệ thống..."
sudo pacman -Syu --noconfirm

echo "Hoàn tất."

# Cài đặt các gói cần thiết
echo "Cài đặt các gói: Hyprland, Neovim, Foot, Wofi, Waybar, Zsh..."
sudo pacman -S --needed --noconfirm hyprland neovim kitty zsh brightnessctl swaybg wl-clipboard otf-comicshanns-nerd noto-fonts-cjk thunar thunar-archive-plugin grim slurp xdg-desktop-portal-hyprland

sudo systemctl enable iwd.service
sudo systemctl start iwd.service

echo "Tạo file blacklist nouveau..."
sudo bash -c 'cat > /etc/modprobe.d/blacklist-nouveau.conf << EOF
blacklist nouveau
options nouveau modeset=0
EOF'

echo "Tạo lại initramfs..."
sudo mkinitcpio -P

# Clone và cài đặt `yay` nếu chưa tồn tại
if [ ! -d "yay" ]; then
  echo "Cloning yay..."
  git clone https://aur.archlinux.org/yay.git
fi

cd yay || exit
echo "Đang build và cài đặt yay..."
makepkg -si --noconfirm
cd ..

cp -rf "$SCRIPT_DIR/.zshrc" $HOME/

# Cài đặt Google Chrome qua yay
echo "Cài đặt Google Chrome..."
yay -S --noconfirm quickshell-git

# 🛠️ Cleanup sau khi cài đặt
echo "Dọn dẹp sau khi cài đặt..."
rm -rf yay

# ✅ Hoàn thành
echo "Quá trình cài đặt hoàn tất! Khởi động lại máy để hoàn tất cấu hình."
read -p "Bạn có muốn reboot không? (y/n): " answer

case "$answer" in
[Yy]*)
  echo "Đang reboot..."
  sudo reboot
  ;;
[Nn]*)
  echo "Hủy reboot."
  exit 0
  ;;
*)
  echo "Vui lòng nhập y hoặc n."
  exit 1
  ;;
esac
