public partial class MainWindow : Window
    {
        private Random random = new Random();
        private List<SecurityEvent> eventsList = new List<SecurityEvent>();
        private bool isDoorsLocked = false;
        private bool isUVRestricted = false;
        private string[] employees = { "Иванов А.И.", "Петров С.К.","Сидоров В.М.", "Кузнецов П.А." };
        public MainWindow()
        {
            InitializeComponent();
            LoadInitialData();
            UpdateData();
            DispatcherTimer timer = new DispatcherTimer();
            timer.Interval = TimeSpan.FromSeconds(10);
            timer.Tick += (s, e) => UpdateData();
            timer.Start();
        }
        private void LoadInitialData()
        {
            AddEvent("Система безопасности запущена", "ИНФО");
            AddEvent("Загрузка конфигурации", "ИНФО");
            AddEvent("Подключение к OPC серверу", "ИНФО");
        }
        private void UpdateData()
        {
            try
            {
                double temperature = 22.0 + (random.NextDouble() * 10 - 3); // 19-25°C
                double voltage = 218.0 + (random.NextDouble() * 12 - 4);    // 214-222В
                double powerFactor = 0.88 + (random.NextDouble() * 0.14);  // 0.88-0.96
                // Обновляем отображение
                txtTemperature.Text = $"{temperature:F1}°C";
                txtVoltage.Text = $"{voltage:F1}В";
                txtPowerFactor.Text = $"{powerFactor:F2}";
                // Проверяем аварийные ситуации
                CheckForAlerts(temperature, voltage, powerFactor);
                // Случайно добавляем событие доступа (30% шанс)
                if (random.Next(0, 10) < 3) // 0,1,2 = 30% шанс
                {
                    AddRandomAccessEvent();
                }
            }
            catch (Exception ex)
            {
                AddEvent($"Ошибка обновления данных: {ex.Message}", "АВАРИЯ");
            }
        }
        private void AddRandomAccessEvent()
        {
            string employee = employees[random.Next(employees.Length)];
            string accessType = random.Next(0, 2) == 0 ? "вход" : "выход";
            AddEvent($"Сотрудник {employee} - {accessType}", "ИНФО");
        }
        private void CheckForAlerts(double temperature, double voltage, double powerFactor)
        {
            bool hasAlert = false;
            if (temperature < 15 || temperature > 30)
            {
                AddEvent($"Температура вне диапазона: {temperature:F1}°C", "АВАРИЯ");
                hasAlert = true;
            }
            if (voltage < 198 || voltage > 242)
            {
                AddEvent($"Напряжение вне диапазона: {voltage:F1}В", "АВАРИЯ");
                hasAlert = true;
            }
            if (powerFactor < 0.8 || powerFactor > 0.99)
            {
                AddEvent($"Коэффициент мощности вне диапазона: {powerFactor:F2}", "АВАРИЯ");
                hasAlert = true;
            }
            // Обновление статуса
            if (hasAlert)
            {
                txtStatus.Text = "АВАРИЯ";
                statusIndicator.Fill = Brushes.Red;
            }
            else
            {
                txtStatus.Text = "НОРМА";
                statusIndicator.Fill = Brushes.Green;
            }
        }
        private void AddEvent(string description, string status)
        {
            var newEvent = new SecurityEvent
            {
                Time = DateTime.Now,
                Description = description,
                Status = status
            };
            // Добавляем в начало списка
            eventsList.Insert(0, newEvent);
            // Обновляем ListView
            listEvents.ItemsSource = null;
            listEvents.ItemsSource = eventsList.Take(15); // Показываем только 15 последних
        }
        // ОБРАБОТЧИКИ СОБЫТИЙ
        private void RefreshButton_Click(object sender, RoutedEventArgs e)
        {
            AddEvent("Ручное обновление данных", "ИНФО");
            UpdateData();
        }
        private void EmergencyAlarm_Click(object sender, RoutedEventArgs e)
        {
            AddEvent("Аварийная сигнализация активирована вручную", "АВАРИЯ");
            txtStatus.Text = "АВАРИЯ";
            statusIndicator.Fill = Brushes.Red;
            // Имитация звуковой и световой сигнализации
            AddEvent("Включена световая и звуковая сигнализация", "ПРЕДУПРЕЖДЕНИЕ");
            MessageBox.Show("Аварийная сигнализация активирована!\n" +
                          "Уведомления отправлены ответственным руководителям.", "АВАРИЯ", MessageBoxButton.OK, MessageBoxImage.Warning);
        }
        private void NotifyManagers_Click(object sender, RoutedEventArgs e)
        {
            AddEvent("Ручная рассылка уведомлений руководителям", "ИНФО");
            MessageBox.Show("Аварийные уведомления отправлены:\n" +
                          "1. Директору тепличного комплекса\n" +
                          "2. Главному инженеру\n" +
                          "3. Начальнику смены", "Уведомления отправлены", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private void LockDoors_Click(object sender, RoutedEventArgs e)
        {
            if (!isDoorsLocked)
            {
                isDoorsLocked = true;
                AddEvent("Все двери и ворота заблокированы", "ПРЕДУПРЕЖДЕНИЕ");
                btnLockDoors.Background = Brushes.Gray;
                btnUnlockDoors.Background = new SolidColorBrush(Color.FromRgb(46, 204, 113));
                MessageBox.Show("Двери и ворота теплицы заблокированы.\n" +
                              "Доступ ограничен.","Блокировка", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }
        private void UnlockDoors_Click(object sender, RoutedEventArgs e)
        {
            if (isDoorsLocked)
            {
                isDoorsLocked = false;
                AddEvent("Двери и ворота разблокированы", "ИНФО");

                btnLockDoors.Background = new SolidColorBrush(Color.FromRgb(243, 156, 18));
                btnUnlockDoors.Background = Brushes.Gray;

                MessageBox.Show("Двери и ворота теплицы разблокированы.\n" +
                              "Доступ восстановлен.", "Разблокировка", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }
        private void UVRestriction_Checked(object sender, RoutedEventArgs e)
        {
            isUVRestricted = true;
            AddEvent("Режим УФ процедуры: доступ ограничен", "ПРЕДУПРЕЖДЕНИЕ");

            // Включаем дополнительные индикаторы (по заданию)
            AddEvent("Включены информационные транспаранты", "ИНФО");
            AddEvent("Активирована мигающая световая индикация", "ИНФО");

            MessageBox.Show("Режим УФ процедуры активирован.\n" +
                          "Доступ в теплицу ограничен.\n" +
                          "Разрешён только в спец.очках.", "УФ процедура", MessageBoxButton.OK, MessageBoxImage.Warning);
        }
        private void UVRestriction_Unchecked(object sender, RoutedEventArgs e)
        {
            isUVRestricted = false;
            AddEvent("Режим УФ процедуры отключён", "ИНФО");
        }
        // Класс для хранения событий
        public class SecurityEvent
        {
            public DateTime Time { get; set; }
            public string Description { get; set; }
            public string Status { get; set; }
        }
    }
