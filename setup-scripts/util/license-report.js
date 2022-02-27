import licenser from '@wbmnky/license-report-generator'

const options = {
  depth: Infinity,
  useDevDependencies: true
}

const getLicenses = async () => {
  const licenserObject = await licenser.reporter.generate(options)

  return licenserObject.plain().licenses
    .map(({ name, license, homepage }) => ({
      homepage,
      license,
      name
    }))
}

getLicenses(() => {})
