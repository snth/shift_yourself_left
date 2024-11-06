SELECT COUNT(*) cnt
FROM {{ source('recipes_raw', 'recipes') }}
