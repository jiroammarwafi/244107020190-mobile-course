double hitungLuasPersegiPanjang(double panjang, double lebar) {
  return panjang * lebar;
}

class Profil {
  String nama;
  String nim;
  String? email;

  Profil({required this.nama, required this.nim, this.email});
}

void main() {
  double panjang = 10.5;
  double lebar = 5.0;
  double luas = hitungLuasPersegiPanjang(panjang, lebar);
  print('Luas persegi panjang: $luas');
  print('---');

  Profil user1 = Profil(
    nama: 'Jiro',
    nim: '2241720000',
    email: 'jiro@example.com',
  );

  Profil user2 = Profil(nama: 'Ammar', nim: '2241720001');

  print('Nama: ${user1.nama}, Email: ${user1.email ?? "Email belum diisi"}');
  print('Nama: ${user2.nama}, Email: ${user2.email ?? "Email belum diisi"}');
}
