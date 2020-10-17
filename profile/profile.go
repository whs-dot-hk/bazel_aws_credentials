package main

import (
	"log"
	"os"
	"text/template"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sts"
	"github.com/spf13/cobra"
)

func run(cmd *cobra.Command, args []string) {
	creds := credentials.NewSharedCredentials(inputCredentialsPath, inputProfileName)

	sess := session.Must(session.NewSession(&aws.Config{
		Credentials: creds,
	}))

	svc := sts.New(sess)

	var outputCredentials *sts.Credentials
	switch cmd.Use {
	case "get-session-token":
		result, err := svc.GetSessionToken(&sts.GetSessionTokenInput{
			DurationSeconds: aws.Int64(28800),
			SerialNumber:    aws.String(serialNumber),
			TokenCode:       aws.String(token),
		})
		if err != nil {
			log.Fatal(err)
		}
		outputCredentials = result.Credentials
	case "assume-role":
		input := &sts.AssumeRoleInput{
			DurationSeconds: aws.Int64(3600),
			RoleArn:         aws.String(roleArn),
			RoleSessionName: aws.String("bazelAwsCredentialsSession"),
		}
		if serialNumber != "" && token != "" {
			input.SerialNumber = aws.String(serialNumber)
			input.TokenCode = aws.String(token)
		}

		result, err := svc.AssumeRole(input)
		if err != nil {
			log.Fatal(err)
		}
		outputCredentials = result.Credentials
	}

	const profileTemplate = `[{{.Name}}]
aws_access_key_id = {{.Credentials.AccessKeyId}}
aws_secret_access_key = {{.Credentials.SecretAccessKey}}
aws_session_token = {{.Credentials.SessionToken}}
`

	t := template.Must(template.New("profile").Parse(profileTemplate))

	file, err := os.Create(outputCredentialsPath)
	if err != nil {
		log.Fatal(err)
	}

	err = t.Execute(file, &Profile{
		Name:        outputProfileName,
		Credentials: outputCredentials,
	})
	if err != nil {
		log.Fatal(err)
	}
}

type Profile struct {
	Name        string
	Credentials *sts.Credentials
}

var (
	// Input credentials
	inputProfileName     string
	inputCredentialsPath string

	// For get session token and assume role
	serialNumber string
	token        string

	// For assume role
	roleArn string

	// Output credentials
	outputProfileName     string
	outputCredentialsPath string

	rootCmd = &cobra.Command{
		Use: "profile",
	}

	getSessionTokenCmd = &cobra.Command{
		Use: "get-session-token",
		Run: run,
	}

	assumeRoleCmd = &cobra.Command{
		Use: "assume-role",
		Run: run,
	}
)

func init() {
	rootCmd.PersistentFlags().StringVar(&inputProfileName, "input-profile-name", "", "input profile name (required)")
	rootCmd.PersistentFlags().StringVar(&inputCredentialsPath, "input-credentials-path", "", "input credentials path (required)")

	rootCmd.PersistentFlags().StringVar(&outputProfileName, "output-profile-name", "", "output profile name (required)")
	rootCmd.PersistentFlags().StringVar(&outputCredentialsPath, "output-credentials-path", "", "output credentials path (required)")

	rootCmd.MarkPersistentFlagRequired("input-profile-name")
	rootCmd.MarkPersistentFlagRequired("input-credentials-path")

	rootCmd.MarkPersistentFlagRequired("region")

	rootCmd.MarkPersistentFlagRequired("output-profile-name")
	rootCmd.MarkPersistentFlagRequired("output-credentials-path")

	getSessionTokenCmd.Flags().StringVar(&serialNumber, "serial-number", "", "serial number (required)")
	getSessionTokenCmd.Flags().StringVar(&token, "token", "", "token (required)")

	getSessionTokenCmd.MarkFlagRequired("serial-number")
	getSessionTokenCmd.MarkFlagRequired("token")

	assumeRoleCmd.Flags().StringVar(&roleArn, "role-arn", "", "role arn (required)")

	assumeRoleCmd.Flags().StringVar(&serialNumber, "serial-number", "", "serial number")
	assumeRoleCmd.Flags().StringVar(&token, "token", "", "token")

	assumeRoleCmd.MarkFlagRequired("role-arn")

	rootCmd.AddCommand(getSessionTokenCmd)
	rootCmd.AddCommand(assumeRoleCmd)
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}
