import json
import degrees_of_kb # imported from github link from requirements.txt

def lambda_handler(event, context):
    # main function for AWS lambda function
    k_b = degrees_of_kb.KevinBacon6Degrees("/wiki/Six_Degrees_of_Kevin_Bacon")
    k_b.generate_6_degrees()
    
    return {
        'statusCode': 200,
        'body': json.dumps(k_b.get_urls())
    }

# Entry point for local execution
if __name__ == "__main__":
    lambda_handler({}, {})
