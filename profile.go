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

	region string

	// For get session token
	serialNumber string
	token        string

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
)

func init() {
	rootCmd.PersistentFlags().StringVar(&inputProfileName, "input-profile-name", "", "input profile name (required)")
	rootCmd.PersistentFlags().StringVar(&inputCredentialsPath, "input-credentials-path", "", "input credentials path (required)")

	rootCmd.PersistentFlags().StringVar(&region, "region", "", "region (required)")

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

	rootCmd.AddCommand(getSessionTokenCmd)
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}
