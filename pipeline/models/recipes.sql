SELECT *
FROM {{ source('recipes_raw', 'recipes') }}
