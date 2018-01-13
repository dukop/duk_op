FactoryGirl.define do
  factory :user do
    sequence(:email){|n| "user#{n}@factory.com" }
    email_confirmation { email }
    password 'f4k3p455w0rd'
    sequence(:username) { |n| "user#{n}" }
    confirmed_at DateTime.now

    factory :admin_user do
      email 'admin@user.com'
      username 'admin'
      is_admin true
    end

    factory :different_user do
      email 'different@user.com'
      username 'different'
    end

    factory :anonymous_user do
      email 'anon@secrets.org'
      username 'anon'
      is_anonymous true
    end
  end

  factory :event do
    title 'Fun party'
    short_description 'really fun party'
    long_description "I'm telling you it's going to be fun!"
    start_time DateTime.now + 10.minutes
    end_time DateTime.now + 5.hours
    location
    user { FactoryGirl.create(:user) }
    categories {[FactoryGirl.create(:random_category)]}
    published true

    factory :event_yesterday do
      title 'This happened yesterday'
      start_time {DateTime.now - 1.days - 2.hours}
      end_time {DateTime.now - 1.days}
    end

    factory :event_tomorrow do
      title 'This will happen tomorrow'
      start_time {DateTime.now + 1.day}
      end_time {DateTime.now + 1.day + 2.hours}
    end

    factory :unpublished_event do
      published false
    end

    factory :featured_event do
      title 'Featured event'
      featured true
    end
  end

  factory :category do
    english :party
    danish 'fest'
  end

  factory :demo_cat, class: Category do
    danish :demo
    english :demonstration
  end

  factory :random_category, class: Category do
    danish { (0...8).map { (65 + rand(26)).chr }.join }
    english { (0...8).map { (65 + rand(26)).chr }.join }
  end

  sequence :name do  |n|
    "Test Location #{n}"
  end

  factory :location do
    name
    street_address 'Stengade 50'
    postcode '2200'
    town 'Nørrebro'
    description 'Folkets Hus er et lokalt, social og politisk brugerstyret hus i hjertet af Nørrebro.'
    latitude 12.554228
    longitude 55.687301

    factory :other_location do
      name
      street_address 'Ragnhildgade 1'
      postcode '2100 Ø'
      description 'warehouse! joints! reggae!'
    end
  end

  factory :comment do
    content 'bla bla bla'
  end

  factory :event_series do
    description 'Sample description'
    start_time (DateTime.now + 1.day).midday
    end_time (DateTime.now + 1.day).midday + 2.hours
    title 'Sample event series'
    rule 'weekly'
    location
    days 'Monday'
    start_date DateTime.now + 1.day
    expiry DateTime.now + 2.month
    user { FactoryGirl.create(:user) }
    categories {[FactoryGirl.create(:random_category)]}

    factory :weekly_series do
      rule 'weekly'
      expiry DateTime.now + 1.month
    end

    factory :biweekly_series_odd do
      rule 'biweekly_odd'
      expiry DateTime.now + 1.month
    end

    factory :biweekly_series_even do
      rule 'biweekly_even'
      expiry DateTime.now + 1.month
    end

    factory :first_in_month do
      rule 'first'
    end

    factory :second_in_month do
      rule 'second'
    end

    factory :third_in_month do
      rule 'third'
    end
    factory :last_in_month do
      rule 'last'
    end

    factory :expired_series do
      expiry DateTime.now - 2.days

      factory :expired_series_expired_warning_sent do
        expired_warning_sent true
      end
    end
    factory :expiring_series do
      expiry DateTime.now + 6.days

      factory :expiring_series_expiring_warning_sent do
        expiring_warning_sent true
      end
    end

  end

  factory :ahoy_event_frontpage, class: Ahoy::Event do
    name 'calendar#index'
    time  DateTime.now - 2.minutes
    properties({ 'locale' => 'da', 'controller' => 'calendar', 'action' => 'index' })
    visit_id nil
    user_id nil

    factory :ahoy_location_show do
      name 'locations#show'
    end
  end

end
