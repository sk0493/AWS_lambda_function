import json
import degrees_of_kb

def lambda_handler(event, context):
    
    k_b = degrees_of_kb.KevinBacon6Degrees("/wiki/Six_Degrees_of_Kevin_Bacon")
    k_b.generate_6_degrees()
    
    return {
        'statusCode': 200,
        'body': json.dumps(k_b.get_urls())
    }