SELECT *
FROM {{ ref('recipe_stats') }}
WHERE cnt<>5
