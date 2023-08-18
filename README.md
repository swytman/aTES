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