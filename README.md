# ATES

## Запуск проекта

Необходим docker, docker-compose.

Используется облачная кафка https://upstash.com/

Для запуска необходимо

1) ``cp .env_template .env``
2) Заполнить в .env KAFKA_USER, KAFKA_PASSWORD, KAFKA_BOOTSTRAP данными из вашего кластера (в моем случае https://upstash.com/)
3) ``chmod +x restart && ./restart``

## Changelog
1) Добавлен сервис авторизации (см. auth).

- Регистрация нового пользователя

    >curl --location 'http://localhost:3001/api/register' \
--header 'Content-Type: application/json' \
--data '{
"user": "user",
"password": "password",
"role": "manager"
}'

- Аутентификация пользователя

    >curl --location 'http://localhost:3001/api/login' \
--header 'Content-Type: application/json' \
--data '{"user": "user", "password": "password", "role": "manager"}'

- Список пользователей

    >curl --location 'http://localhost:3001/api/users'

2) При создании пользователя в топик user-streams улетает сообщение UserCreated
3) Добавлен сервис таск-трекера (см. todo)

- Список пользователей (заполняется из событий users-stream)
  >curl --location 'http://localhost:3002/api/users'

- Список задач (user видит только свои)
  >curl --location 'http://localhost:3002/api/tasks' \
  --header 'Authorization: jwt_token'

- Создание задачи
    >curl --location 'http://localhost:3002/api/tasks' \
--header 'Content-Type: application/json' \
--header 'Authorization: jwt_token' \
--data '{"description": "description task"}'

- Переназначение задач (доступно для manager и admin)

    >curl --location --request POST 'http://localhost:3002/api/tasks/reassign' \
  --header 'Content-Type: application/json' \
  --header 'Authorization: jwt_token'

- Завершение задачи (доступно для исполнителя)

    >curl --location --request POST 'http://localhost:3002/api/tasks/35/resolve' \
  --header 'Authorization: jwt_token'

4) При создании задачи в топик tasks-stream создается сообщение TaskCreated
5) При переназначении задачи в топик tasks-stream создается сообщение TaskReassigned
6) При завершении задачи в топик tasks-stream создается сообщение TaskResolved
7) Сервис todo_karafka слушает users-stream и синхронизирует данные по пользователям

## Добавлено на 3-й неделе

1) Схемы событий вынесены в новые репозиторий https://github.com/swytman/popug_schema_registry (не все, в процессе)
2) Добавлен сервис accounting, который:
- обрабатывает бизнес-событий TaskAssigned, TaskResolved, TaskReassigned,
а также стримы аккаунтов и задач
- создает транзакции withdrawal, deposit, payment (в принципе по аналогии с факультативом)
- стримит создание транзакций в transactions-stream для аналитики (событие TransactionCreated)
- стримит закрытие транзакции по окончанию дня в transactions-stream (событие TransactionUpdated)

3) В сервисе accounting добавлен GET /api/profile для просмотра попугом своего текущего баланса и логов транзакций
4) В сервисе accounting добавлен GET /api/stats для просмотра бухгалтером текущего баланса
компании, а также статистика прошлых дней
5) (неофициально) В сервисе accounting добавлен POST /api/day_finish, который инициирует событие закрытия
дня для всего аккаунтинга. Любой попуг может инициировать закрытие дня, чтобы успеть хоть что-то заработать
пока менедежеры не задушили массовым переназначением задач. А мне так удобнее отлаживать.
6) Сервис аналитики - TODO
7) Миграция на новое событие c jira-id - TODO

Как буду мигрировать на новое событие:
1) Добавлю в sсhema-registry новую версию v2 с новым полем jira-id
2) Во всех сервисах добавлю в БД новое поле tasks.jira_id
3) Добавлю во всех consumers обработку этого события, чтобы они могли работать с двумя версиями
4) Переключу producer на v2, поправлю API и добавлю парсинг jira-id из title