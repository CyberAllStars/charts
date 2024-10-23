package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v3"
)

type Chart struct {
	Dependencies []struct {
		Name       string `yaml:"name"`
		Repository string `yaml:"repository"`
		Condition  string `yaml:"condition,omitempty"`
		Version    string `yaml:"version,omitempty"`
	} `yaml:"dependencies"`
}

func main() {
	data, err := ioutil.ReadFile("Chart.yaml")
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}

	var chart Chart
	if err := yaml.Unmarshal(data, &chart); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}

	repoBucket := make(map[string]struct{})

	for _, dep := range chart.Dependencies {
		if _, ok := repoBucket[dep.Name]; ok {
			fmt.Printf("Skipping %s as it already exists\n", dep.Name)
			continue
		}

		repoBucket[dep.Name] = struct{}{}

		if err := addRepository(dep.Name, dep.Repository); err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			os.Exit(1)
		}

		if err := updateDependency(&dep); err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			os.Exit(1)
		}

		if err := saveDefaultValues(dep); err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			os.Exit(1)
		}
	}

	chart.Dependencies = removeDuplicates(chart.Dependencies)

	data, err = yaml.Marshal(chart)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}

	if err := ioutil.WriteFile("Chart.yaml", data, 0644); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func addRepository(name, repo string) error {
	fmt.Printf("Adding %s from %s\n", name, repo)
	return runCmd("helm", "repo", "add", name, repo)
}

func updateDependency(dep *struct {
	Name       string `yaml:"name"`
	Repository string `yaml:"repository"`
	Condition  string `yaml:"condition,omitempty"`
	Version    string `yaml:"version,omitempty"`
}) error {
	fmt.Printf("Updating %s to latest version\n", dep.Name)
	out, err := runCmdWithOutput("helm", "search", "repo", fmt.Sprintf("%s/%s", dep.Name, dep.Name))
	if err != nil {
		return err
	}

	latestVersion := strings.Split(out, " ")[1]
	dep.Version = latestVersion
	dep.Condition = fmt.Sprintf("%s.enabled", dep.Name)

	return nil
}

func saveDefaultValues(dep struct {
	Name       string `yaml:"name"`
	Repository string `yaml:"repository"`
	Condition  string `yaml:"condition,omitempty"`
	Version    string `yaml:"version,omitempty"`
}) error {
	fmt.Printf("Saving default values for %s\n", dep.Name)
	folder := filepath.Join("values", "examples", "defaults")
	if err := os.MkdirAll(folder, 0755); err != nil {
		return err
	}

	regRepo := fmt.Sprintf("%s/%s", dep.Name, dep.Name)
	out, err := runCmdWithOutput("helm", "show", "values", regRepo)
	if err != nil {
		return err
	}

	fname := filepath.Join(folder, fmt.Sprintf("%s_default_values.yaml", dep.Name))
	return ioutil.WriteFile(fname, []byte(out), 0644)
}

func removeDuplicates(dependencies []struct {
	Name       string `yaml:"name"`
	Repository string `yaml:"repository"`
	Condition  string `yaml:"condition,omitempty"`
	Version    string `yaml:"version,omitempty"`
}) []struct {
	Name       string `yaml:"name"`
	Repository string `yaml:"repository"`
	Condition  string `yaml:"condition,omitempty"`
	Version    string `yaml:"version,omitempty"`
} {
	seen := make(map[string]bool)
	var result []struct {
		Name       string `yaml:"name"`
		Repository string `yaml:"repository"`
		Condition  string `yaml:"condition,omitempty"`
		Version    string `yaml:"version,omitempty"`
	}

	for _, dep := range dependencies {
		if !seen[dep.Name] {
			seen[dep.Name] = true
			result = append(result, dep)
		}
	}

	return result
}

func runCmd(cmd string, args ...string) error {
	c := exec.Command(cmd, args...)
	c.Stdout = os.Stdout
	c.Stderr = os.Stderr
	return c.Run()
}

func runCmdWithOutput(cmd string, args ...string) (string, error) {
	c := exec.Command(cmd, args...)
	output, err := c.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("error running %q: %v", cmd, err)
	}
	return string(output), nil
}
