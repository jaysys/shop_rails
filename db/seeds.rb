categories = [
  { name: "패션", slug: "fashion" },
  { name: "키보드", slug: "keyboard" },
  { name: "오디오", slug: "audio" },
  { name: "데스크셋업", slug: "desk-setup" },
  { name: "모바일", slug: "mobile" },
  { name: "라이프스타일", slug: "lifestyle" },
  { name: "사무용품", slug: "office-supplies" },
  { name: "홈오피스", slug: "home-office" }
]

categories_by_name = categories.each_with_object({}) do |entry, acc|
  category = Category.find_or_initialize_by(slug: entry[:slug])
  category.name = entry[:name]
  category.save!
  acc[entry[:name]] = category
end

products = [
  { name: "Rails Hoodie", description: "가볍고 따뜻한 후드. 일상/개발 밋업 모두 잘 어울립니다.", price: 59000, image: "rails_hoodie.svg", categories: ["패션", "라이프스타일"] },
  { name: "Mechanical Keyboard", description: "장시간 타이핑에 맞춘 텐키리스 키보드.", price: 129000, image: "mechanical_keyboard.svg", categories: ["키보드", "데스크셋업", "사무용품"] },
  { name: "USB-C Dock", description: "HDMI/USB-A/PD 충전을 지원하는 멀티 도크.", price: 89000, image: "usb_c_dock.svg", categories: ["모바일", "데스크셋업", "홈오피스"] },
  { name: "Noise-Cancel Headphones", description: "집중을 위한 액티브 노이즈 캔슬링 헤드폰.", price: 199000, image: "noise_cancel_headphones.svg", categories: ["오디오", "홈오피스", "라이프스타일"] },
  { name: "Ergonomic Mouse", description: "손목 부담을 줄이는 인체공학 무선 마우스.", price: 79000, image: "ergonomic_mouse.svg", categories: ["데스크셋업", "사무용품"] },
  { name: "Portable SSD 1TB", description: "사진/영상 작업에 적합한 고속 외장 SSD.", price: 149000, image: "portable_ssd.svg", categories: ["모바일", "데스크셋업"] },
  { name: "Studio Lamp", description: "밝기/색온도 조절이 가능한 데스크 조명.", price: 69000, image: "studio_lamp.svg", categories: ["홈오피스", "데스크셋업"] },
  { name: "Minimal Desk Mat", description: "키보드와 마우스를 안정적으로 받쳐주는 대형 매트.", price: 29000, image: "desk_mat.svg", categories: ["데스크셋업", "사무용품"] },
  { name: "Smart Phone Stand", description: "각도 조절 가능한 메탈 스마트폰 거치대.", price: 25000, image: "phone_stand.svg", categories: ["모바일", "사무용품"] },
  { name: "Canvas Tote Bag", description: "노트북과 소지품을 담기 좋은 데일리 토트백.", price: 39000, image: "canvas_tote_bag.svg", categories: ["패션", "라이프스타일"] },
  { name: "Wireless Presenter", description: "회의와 강의용 무선 프레젠터.", price: 47000, image: "wireless_presenter.svg", categories: ["사무용품", "홈오피스"] },
  { name: "Ceramic Mug Set", description: "업무 중 티타임을 위한 세라믹 머그 세트.", price: 33000, image: "ceramic_mug_set.svg", categories: ["라이프스타일", "홈오피스"] },
  { name: "Laptop Sleeve 14\"", description: "충격 완화 패드가 들어간 노트북 슬리브.", price: 42000, image: "laptop_sleeve.svg", categories: ["패션", "모바일"] },
  { name: "Bluetooth Speaker Mini", description: "컴팩트 사이즈의 휴대용 블루투스 스피커.", price: 56000, image: "bluetooth_speaker_mini.svg", categories: ["오디오", "모바일", "라이프스타일"] },
  { name: "Analog Wall Clock", description: "공간 분위기를 살리는 미니멀 월 클락.", price: 38000, image: "analog_wall_clock.svg", categories: ["라이프스타일", "홈오피스"] }
]

products.each do |attrs|
  image_file = attrs[:image]
  names = attrs[:categories]

  product = Product.find_or_initialize_by(name: attrs[:name])
  product.description = attrs[:description]
  product.price = attrs[:price]
  product.save!

  product.categories = names.map { |name| categories_by_name.fetch(name) }

  image_path = Rails.root.join("db/sample_images", image_file)
  if File.exist?(image_path)
    next if product.image.attached? && product.image.filename.to_s == image_file

    product.image.attach(
      io: File.open(image_path),
      filename: image_file,
      content_type: "image/svg+xml"
    )
  end
end

puts "Seed complete: categories=#{Category.count}, products=#{Product.count}"
